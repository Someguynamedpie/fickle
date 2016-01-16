package.path = "game/?.lua;game/?/init.lua"

local args = require( "lib.commandline" )( {...}, "" )
DEDICATED = args.dedicated

fickle = {}
local atexit = {}
local running = true
function fickle.exit( warn )
  running = false
end
function fickle.atexit( cb ) table.insert( atexit, cb ) end


local ffi=require'ffi'
local exLoad = ffi.load
function ffi.load(p,...)
	local suc,ret = pcall(exLoad,p,...)
	if not suc then return exLoad('bin/lib' .. p .. '.so', ... ) end
	return ret
end
require( "lib.color" )
sdl = require( "lib.sdl2" )
local log = require('log')

require('util.string')
class = require( "lib.middleclass" )
local console = require('console')
require( "binds" )

function math.round(num, idp)
	if not num then error'FUCK YOU YOU ASSWIPE IF YOU WANT MET TO ROUND GIVE ME A DAMN NUMBER TO ROUND' end
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function fickle.suppressStdout(bool)
	suppress = bool
end



tween = require( "lib.tween" )
require'lib.utf8'
Stack = require( "lib.stack" )
if not DEDICATED then
	video = require( "video" )
	audio = require( "audio" )
	input = require( "video.input" )
	video.ft = require( 'video.freetype' )
	gui   = require( "gui" )

	local console = require('gui.console')
	for k,v in pairs(log.history) do
		console.onlog(unpack(v))
	end
	log.history = nil
	history = nil
	--console.toggle()

	video.setTitle( "Space Station 13" )
end



function fickle.getRealTime()
	return sdl.GetTicks() / 1000
end


require( "net.net" ) net.init()

if not DEDICATED then
	require( "game" )
end

function fickle.cleanup()
	print( "Cleaning up..." )
	for k,v in pairs( atexit ) do
		local suc, err = pcall(v)
		if not suc then print( "Exit hook error: ", err ) end
	end
	if not DEDICATED then
		
		audio.cleanUp()
		gui.clear()
		video.cleanUp()
	end
	sdl.cleanUp()
	print( "Exited cleanly." )
	fickle.clean = true
end
local ticks = sdl.GetTicks()
local dt = 0

_G.__EXITPROXY = newproxy(true)
getmetatable(__EXITPROXY).__gc = function()
	if fickle.clean then return end
	if not fickle.expected then
		print( "Irregular Shutdown!" )
	end
	fickle.cleanup()
end

print( "Beginning main event loop..." )




local music = require( 'audio.music' )
--music.setQueue( {audio.loadSource( 'BEMainMenuMusic.ogg' )} )
--local tex = Texture( "fickle.png" )
local eventQueue = Stack:new()
function fickle.pushEvent( type, data, gui )
	eventQueue:push( {type = type, data = data, gui = gui} )
end

local handlers = {}

function fickle.pollEvents()
	for i = 1, #eventQueue.stack do
		local evt = eventQueue:pop()
		local bubble = true
		if evt.gui then if gui.pushEvent( evt.type, evt.data ) then bubble = false end end--gui priority
		if handlers[ evt.type ] and bubble then
			for k2, v2 in ipairs( handlers[evt.type] ) do
				bubble = not (v2( evt.type, evt.data )==false)
			end
		end
	end
end

local timers = {}
local system = require'system'
function fickle.addTimer( name, delay, repetitions, callback, ... )
	timers[ name ] = { next = system.getTime() + delay, delay = delay, repetitions = repetitions, callback = callback, args = {...} }
end

function fickle.timerThink()
	for k, v in pairs( timers ) do
		if( v.next <= system.getTime() ) then
			v.repetitions = v.repetitions - 1
			if( v.repetitions == 0 ) then --Not a less/equal check because 0 = loop until canceled
				timers[ k ] = nil
			end
			v.next = system.getTime() + v.delay
			v.callback( unpack( v.args ) )
		end
		
	end
end

function fickle.hookEvent( type, cb )
	handlers[ type ] = handlers[ type ] or {}
	table.insert( handlers[ type ], cb )
end

--package.path = package.path .. ";gamemodes/planet/gamemode/?.lua;gamemodes/planet/gamemode/?/init.lua"
--Launch game
require'sandgoon.menu'
--/game
if DEDICATED then
	--net.host( '*', 7777 )
else
	--net.connect('localhost', 7777)
end
console.execute( io.open( 'cfg/autoexec.cfg' ):read'*a' )
local fpsAvg = 0
while running do
	console.update()
	if not DEDICATED then
		video.update()

		gui.update()
		--surface.setDrawColor( 255, 126, 0 )
		--surface.fillCircle( 100, 100, 100 )
	end

	fickle.pollEvents()
	tween.update()
	fickle.timerThink()
	--
	surface.setClipRect()
	surface.setScale(1,1)
	surface.setTranslation(0,0)

	if dt > 0 then
	if fpsAvg == 0 then fpsAvg = 1/dt else fpsAvg = ( fpsAvg + (1/dt) ) / 2 end
	end
	
	if not DEDICATED then
		surface.drawText( "FPS: " .. math.floor( fpsAvg ), ScrW - 200, 10 )
		video.present()
		audio.update()
	end
	net.poll()
	dt = (sdl.GetTicks() - ticks) / 1000
	--sdl.Delay( math.min( math.max( 16 - (sdl.GetTicks() - ticks), 0 ), 16 ) )
	ticks = sdl.GetTicks()


end
fickle.expected = true
fickle.cleanup()
