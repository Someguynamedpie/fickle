local M = {}

function M.startTextInput( x, y, w, h )
	sdl.StartTextInput()
	sdl.SetTextInputRect( surface.getRect( x, y, w, h ) )
end
function M.finishTextInput()
	sdl.StopTextInput()
end

MOD_SHIFT = sdl.KMOD_LSHIFT + sdl.KMOD_RSHIFT
MOD_CTRL  = sdl.KMOD_LCTRL + sdl.KMOD_RCTRL
MOD_ALT   = sdl.KMOD_LALT + sdl.KMOD_RALT

local band= bit.band
function M.hasModifier( mods, modifier )
	return band( mods, modifier ) > 0
end

function M.getMousePos()
	return M.mX or 0, M.mY or 0
end

return M