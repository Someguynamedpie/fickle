local ffi = require( 'ffi' )
local devil = require( "lib.devil" )
local dmireader = require'lib.dmi'
local iName = ffi.new( 'ILuint[1]' )
devil.GenImages( 1, iName )
devil.BindImage( iName[0] )

local texCache = {}
function Texture( path, dmi )
	--path = path:lower()
	if texCache[ path ] then return texCache[ path ] end
	local dmi
	if dmi or path:find'%.dmi' then
		dmi = dmireader.readDMI( path )
	end
	if devil.LoadImage( "textures/" .. path ) == 1 then
		devil.ConvertImage( devil.RGBA, devil.UNSIGNED_BYTE )
		local surface = sdl.CreateRGBSurface(
			0, devil.GetInteger(devil.IMAGE_WIDTH), devil.GetInteger(devil.IMAGE_HEIGHT), 32, 0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000
		)
		if( surface == ffi.null ) then error( "COULDNT CREATE TEXTURE: " .. ffi.string( sdl.GetError() ) ) end

		sdl.LockSurface( surface )
		sdl.memcpy( surface.pixels, devil.GetData(), devil.GetInteger(devil.IMAGE_WIDTH) * devil.GetInteger(devil.IMAGE_HEIGHT) * devil.GetInteger(devil.IMAGE_BYTES_PER_PIXEL) )
		sdl.UnlockSurface( surface )

		local tex = sdl.CreateTextureFromSurface( video.renderer, surface )
		sdl.SetTextureBlendMode( tex, sdl.BLENDMODE_BLEND )
		devil.DeleteImages( 1, iName )
		devil.GenImages( 1, iName )
		devil.BindImage( iName[0] )

		local proxy = newproxy(true)

		local tbl = { width = surface.w, height = surface.h, tex = tex, path = path, __gc = proxy, dmi = dmi, path = path }
		getmetatable(proxy).__gc = function()
			sdl.DestroyTexture( tex )
		end
		sdl.FreeSurface( surface )

		return tbl
	else
		print( "Failed to load texture: " .. devil.GetError() )
	end
end
devil.Init()
local tmeta = class( "video.Texture" )
function tmeta:initialize( opts )
	self.tex = opts.tex
	self.width = opts.width
	self.height = opts.height
	self.path = opts.path
end
function tmeta:lock(x, y, w, h)
	local pixels = ffi.new('unsigned char*[1]')
	local pitch = ffi.new( 'int[1]' )
	sdl.LockTexture( self.tex, surface.getRect( x or 0, y or 0, w or self.width, h or self.height ), ffi.cast( 'void**', pixels ), pitch )

	return pixels[0], pitch[ 0 ]
end
function tmeta:unlock()
	sdl.UnlockTexture( self.tex )
end
TEXTURE_STREAMING = sdl.TEXTUREACCESS_STREAMING
TEXTURE_STATIC    = sdl.TEXTUREACCESS_STATIC
function CreateTexture( w, h, format, mode, blend )
	format = format or sdl.PIXELFORMAT_ABGR8888--integer access is faster but more memory used; as long as we dont set the blend mode alpha channel is ignored
	mode = mode or sdl.TEXTUREACCESS_STREAMING
	local tex = sdl.CreateTexture( video.renderer, format, mode, w, h )
	assert( tex ~= ffi.null, ffi.string( sdl.GetError() ) )
	if blend then
		sdl.SetTextureBlendMode( tex, blend )
	end
	return tmeta:new{tex = tex, width = w, height = h, path = 'created'}
end
