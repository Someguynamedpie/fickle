local M = {}
local ffi = require( 'ffi' )
--gfx = require'lib.sdl2gfx'
function M.init()--956, 956
	M.window = sdl.CreateWindow( "SS13 - Launching", sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED, 736, 736, sdl.WINDOW_RESIZABLE )
	M.renderer = sdl.CreateRenderer( M.window, -1, sdl.RENDERER_ACCELERATED + sdl.RENDERER_PRESENTVSYNC )
	surface = require( "video.surface" ).init( M.renderer )
	ScrW = 736
	ScrH = 736
end
FORMAT_ARGB = {0x00FF0000, 0x0000FF00, 0x000000FF, 0xFF000000}
FORMAT_RGB = {0xFF0000, 0x00FF00, 0x0000FF, 0}
FORMAT_ABGR = {0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000}

function M.createSurface( width, height, format )
	return sdl.CreateRGBSurface( 0, width, height, format[4] == 0 and 24 or 32, unpack( format ) )
end

function M.createTexture( surface, dontDelete )
	local tex = sdl.CreateTextureFromSurface( M.renderer, surface )
	if not dontDelete then sdl.FreeSurface( surface ) end
	return tex
end
MOUSE_LEFT = sdl.BUTTON_LEFT
MOUSE_MIDDLE = sdl.BUTTON_MIDDLE
MOUSE_RIGHT = sdl.BUTTON_RIGHT


local event = ffi.new( 'SDL_Event' )
local toggle=false
local input = require'video.input'
function M.update()
	while sdl.PollEvent( event ) ~= 0 do
		if event.type == sdl.QUIT then
			fickle.exit( true )
			return
		elseif event.type == sdl.MOUSEMOTION then
			local motion = event.motion
			input.mX = motion.x
			input.mY = motion.y
			fickle.pushEvent( "mousemove", {x = motion.x, y = motion.y, rx = motion.xrel, ry = motion.yrel}, true )
		elseif event.type == sdl.MOUSEBUTTONDOWN then
			local button = event.button
			fickle.pushEvent( "mousepress", {button = button.button, clicks = button.clicks, x = button.x, y = button.y}, true )
		elseif event.type == sdl.MOUSEBUTTONUP then
			local button = event.button
			fickle.pushEvent( "mouserelease", {button = button.button, clicks = button.clicks, x = button.x, y = button.y}, true )
		elseif event.type == sdl.TEXTEDITING then
			fickle.pushEvent( "textime", {text = ffi.string(event.edit.text), start = event.edit.start, length = event.edit.length}, true )
		elseif event.type == sdl.TEXTINPUT then
			fickle.pushEvent( "textinput", {text = ffi.string(event.edit.text)}, true )
		elseif event.type == sdl.KEYDOWN then
			--if(event.key.keysym.sym == sdl.KEY_c) then fickle.exit() return end
			fickle.pushEvent( "keydown", {key = event.key.keysym.sym, modifiers = event.key.keysym.mod, rep = event.key['repeat'] > 0 }, true )
      
		elseif event.type == sdl.KEYUP then
			fickle.pushEvent( "keyup", {key = event.key.keysym.sym, modifiers = event.key.keysym.mod, rep = event.key['repeat'] > 0 }, true )
		elseif event.type == sdl.WINDOWEVENT then
			if event.window.event == sdl.WINDOWEVENT_RESIZED then
				ScrW = event.window.data1
				ScrH = event.window.data2
				fickle.pushEvent( "resize", {w = event.window.data1, h = event.window.data2}, true)
			end
		elseif event.type == sdl.MOUSEWHEEL then
			local x, y = event.wheel.x, event.wheel.y
			if event.wheel.direction == sdl.MOUSEWHEEL_FLIPPED then
				x = -x y = -y
			end
			fickle.pushEvent( "scroll", {x = x, y = y}, true )
		end
	end
	surface.setAlphaMultiplier( 1 )
	surface.setTranslation( 0, 0 )
	surface.setScale( 1, 1 )
	surface.setClipRect()
	surface.setDrawColor( color_skyblue )
	sdl.RenderClear( video.renderer )
end

function M.present()
	sdl.RenderPresent( M.renderer )
end

function M.setTitle( newTitle )
	sdl.SetWindowTitle( M.window, newTitle )
end
function M.getSize()
	local w, h = ffi.new( 'int[1]' ), ffi.new( 'int[1]' )
	sdl.GetWindowSize( M.window, w, h )
	return w[0], h[0]
end

function M.cleanUp()
	sdl.DestroyWindow( M.window )
	io.write'Cleaning up..\n'
end

M.init()

M.cleanTextures = require( "video.texture" )

require( "video.atlas" )

return M
