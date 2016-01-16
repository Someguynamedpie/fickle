local ffi = require( 'ffi' )
local M = {}

function M.getClipboardText()
    local str = sdl.GetClipboardText()

    local ret = ffi.string(str)
    sdl.free( str )
    return ret
end

function M.setClipboardText(str)
	sdl.SetClipboardText( str )
end

function M.getTime()
    return sdl.GetTicks() / 1000
end

function M.sleep( ms )
	sdl.Delay( ms )
end

return M
