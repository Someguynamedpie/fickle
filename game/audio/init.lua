local M = {}

local GLOBAL_VOLUME = 1

local ffi = require'ffi'
local al = require( 'lib.openal' )
local stb = require( 'lib.stbvorbis' )
local devices = al.alcGetString( nil, al.ALC_ALL_DEVICES_SPECIFIER )
--ffi.cdef[[int strlen(const char*str);]]
local device = al.alcOpenDevice( devices )

local context = al.alcCreateContext( device, nil )
if(al.alcMakeContextCurrent( context ) ~= 1) then error("FUCK") end
--print(ffi.string(devices,256):gsub('\0','.'))

local intBuff = ffi.new( 'ALuint[1]' )

local bmeta = {}
bmeta.__index = bmeta
function bmeta:getInt( id )
	al.alGetBufferi( self.id, id, intBuff )
	return intBuff[0]
end
function bmeta:getSize()
	self.size = self.size or self:getInt( al.AL_SIZE )
	return self.size
end
function bmeta:getFrequency()
	self.frequency = self.frequency or self:getInt( al.AL_FREQUENCY )
	return self.frequency
end
function bmeta:getBits()
	self.bits = self.bits or self:getInt( al.AL_BITS )
	return self.bits
end
function bmeta:getChannels()
	self.channels = self.channels or self:getInt( al.AL_CHANNELS )
	return self.channels
end
function bmeta:upload( buffer, size, channels, sampleRate )
	al.alBufferData( self.id, channels == 1 and al.AL_FORMAT_MONO16 or al.AL_FORMAT_STEREO16, buffer, size * 2, sampleRate )
end
local err = ffi.new( 'int[1]' )
function bmeta:loadOGG( path )
	local vorbis = stb.vorbis_open_filename( 'sound/' .. path, err, nil )
	if vorbis == ffi.null then
		error( "Failed to decode OGG stream: " .. err[0] )
	end
	local info = stb.vorbis_get_info( vorbis )
	local sampleCount = stb.vorbis_stream_length_in_samples(vorbis) * info.channels
	local samples = ffi.new( 'ALshort[?]', sampleCount )
	stb.vorbis_get_samples_short_interleaved( vorbis, info.channels, samples, sampleCount );
	self:upload( samples, sampleCount, info.channels, info.sample_rate )
	stb.vorbis_close( vorbis )
end
function bmeta:delete()
	intBuff[0] = self.id
	al.alDeleteBuffers( 1, intBuff )
end

function bmeta:getDuration()
	return (self:getSize() * 8 / (self:getChannels() * self:getBits())) / self:getFrequency()
end

BUFFER_STREAMING = 1 -- TODO
BUFFER_STATIC    = 2
function M.createBuffer(type)
	al.alGenBuffers( 1, intBuff )
	return setmetatable( {id = intBuff[0]}, bmeta )
end

local sourceEffectQueue = {}

local smeta = {} smeta.__index = smeta
function smeta:getBuffer( ) return self.buffer end
function smeta:setInt( type, int ) al.alSourcei( self.id, type, int ) end
function smeta:getInt( type ) al.alGetSourcei( self.id, type, intBuff ) return intBuff[0] end
local floatBuff = ffi.new( 'ALfloat[1]' )
local posBuff = ffi.new( 'ALfloat[3]' )
function smeta:setFloat( type, float ) al.alSourcef( self.id, type, float ) end
function smeta:getFloat( type ) al.alGetSourcef( self.id, type, floatBuff ) return floatBuff[0] end
function smeta:play()
	al.alSourcePlay( self.id )
end
function smeta:pause()
	al.alSourcePause( self.id )
end
function smeta:stop()
	al.alSourceStop( self.id )
	self:clearEffects()
end
function smeta:rewind()
	al.alSourceRewind( self.id )
end
function smeta:setPitch( pitch )
	self:setFloat( al.AL_PITCH, pitch )
end
function smeta:setPan( pan )
	posBuff[ 0 ] = pan
	al.alSourcefv( self.id, al.AL_POSITION, posBuff )
end
function smeta:setPos( x, y )
	posBuff[ 0 ] = x
	posBuff[ 1 ] = y
	al.alSourcefv( self.id, al.AL_POSITION, posBuff )
end
function smeta:setGain( pitch )
	self.gain = pitch
	self:setFloat( al.AL_GAIN, pitch * GLOBAL_VOLUME )
end
function smeta:getPitch( )
	return self:getFloat( al.AL_PITCH )
end
function smeta:getGain( )
	return self.gain or self:getFloat( al.AL_GAIN )
end
function smeta:getDuration()
	return self:getBuffer():getDuration() * self:getPitch()
end
function smeta:getOffset()
	return self:getFloat( al.AL_SAMPLE_OFFSET ) / self:getBuffer():getFrequency()
end


function smeta:attachEffect( effect )
	table.insert( self.effects, effect )
	if( not sourceEffectQueue[ self ] ) then sourceEffectQueue[ self ] = true end
end
function smeta:removeEffect( effect )
	for k, v in pairs( self.effects ) do
		if( v == effect ) then
			table.remove( self.effects, k )
			break
		end
	end
	if( #self.effects == 0 ) then sourceEffectQueue[ self ] = nil end
end
function smeta:update()
	for k, v in pairs( self.effects ) do

		v:update( self )
	end
end
function smeta:clearEffects()
	self.effects = {}
	sourceEffectQueue[ self ] = nil
end

function smeta:delete()
	intBuff[0] = self.id
	al.alDeleteSources( 1, intBuff )
end
function M.createSource( buffer )
	al.alGenSources( 1, intBuff )
	local id = intBuff[0]
	intBuff[0] = buffer.id
	al.alSourceQueueBuffers( id, 1, intBuff )
	al.alSourcei( id, al.AL_BUFFER, buffer.id );
	return setmetatable( {buffer = buffer, id = id, effects = {}}, smeta )
end

function M.setCamPos( x, y )
	al.alListener3f( al.AL_POSITION, x, y, 0 )
end

local bufferCache = {}

function M.getVolume()
	return GLOBAL_VOLUME
end
function M.setVolume( vol )
	GLOBAL_VOLUME = vol
	for k, v in pairs( bufferCache ) do
		for k2, v2 in pairs( v.sources ) do
			v2:setGain( v2:getGain() )
		end
	end
end

AUDIO_MAX_SOURCES = 5
function M.loadSource( path, type, reserve )
	local buffer
	local source
	if bufferCache[ path ] then
		buffer = bufferCache[ path ]
		local doRet = false
		if #buffer.sources >= AUDIO_MAX_SOURCES then
			insertCache = false
			buffer.cycle = buffer.cycle + 1
			if buffer.cycle > #buffer.sources then
				buffer.cycle = 1
			end
			return buffer.sources[ buffer.cycle ]
		end
	else
		buffer = M.createBuffer( type )
		if(path:find('%.ogg')) then
			buffer:loadOGG( path )
		end
		bufferCache[ path ] = bufferCache[ path ] or { sources = {}, buffer = buffer, cycle = 0 }
		buffer = bufferCache[ path ]
	end
	source = M.createSource( buffer.buffer )
	source:setGain( GLOBAL_VOLUME )
	table.insert( bufferCache[ path ].sources, source )
	return source
end
function M.play( path )
	local src = M.loadSource( path, nil ) return src, src:play()
end

function M.cleanUp()
	for k,v in pairs( bufferCache ) do
		for k2, v2 in pairs( v.sources ) do
			v2:stop()
			v2:delete()
		end
		v.buffer:delete()
	end
	al.alcDestroyContext( context )
	al.alcCloseDevice( device )
end

function M.update()
	for k,v in pairs( sourceEffectQueue ) do
		if v then k:update() end
	end
end

require( "audio.effects" )

return M
