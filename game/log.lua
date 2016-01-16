local M = {}

LOG_PRIORITY_VERBOSE  = sdl.LOG_PRIORITY_VERBOSE
LOG_PRIORITY_DEBUG    = sdl.LOG_PRIORITY_DEBUG
LOG_PRIORITY_INFO     = sdl.LOG_PRIORITY_INFO
LOG_PRIORITY_WARN     = sdl.LOG_PRIORITY_WARN
LOG_PRIORITY_ERROR    = sdl.LOG_PRIORITY_ERROR
LOG_PRIORITY_CRITICAL = sdl.LOG_PRIORITY_CRITICAL

LOG_CATEGORY_APPLICATION = sdl.LOG_CATEGORY_APPLICATION
LOG_CATEGORY_ERROR       = sdl.LOG_CATEGORY_ERROR
LOG_CATEGORY_ASSERT      = sdl.LOG_CATEGORY_ASSERT
LOG_CATEGORY_SYSTEM      = sdl.LOG_CATEGORY_SYSTEM
LOG_CATEGORY_AUDIO       = sdl.LOG_CATEGORY_AUDIO
LOG_CATEGORY_VIDEO       = sdl.LOG_CATEGORY_VIDEO
LOG_CATEGORY_RENDER      = sdl.LOG_CATEGORY_RENDER
LOG_CATEGORY_INPUT       = sdl.LOG_CATEGORY_INPUT
LOG_CATEGORY_TEST        = sdl.LOG_CATEGORY_TEST

M.categories = {
	[LOG_CATEGORY_APPLICATION] = 'app',
	[LOG_CATEGORY_ERROR      ] = 'error',
	[LOG_CATEGORY_ASSERT     ] = 'assert',
	[LOG_CATEGORY_SYSTEM     ] = 'system',
	[LOG_CATEGORY_AUDIO      ] = 'audio',
	[LOG_CATEGORY_VIDEO      ] = 'video',
	[LOG_CATEGORY_RENDER     ] = 'render',
	[LOG_CATEGORY_INPUT      ] = 'input',
	[LOG_CATEGORY_TEST       ] = 'test',
}

M.priorities = {
	[LOG_PRIORITY_VERBOSE ] = 'verbose',
	[LOG_PRIORITY_DEBUG   ] = 'debug',
	[LOG_PRIORITY_INFO    ] = 'info',
	[LOG_PRIORITY_WARN    ] = 'warn',
	[LOG_PRIORITY_ERROR   ] = 'error',
	[LOG_PRIORITY_CRITICAL] = 'critical',
}
M.colors = {
	[LOG_PRIORITY_VERBOSE ] = color_skyblue,
	[LOG_PRIORITY_DEBUG   ] = color_green,
	[LOG_PRIORITY_INFO    ] = color_blue,
	[LOG_PRIORITY_WARN    ] = color_yellow,
	[LOG_PRIORITY_ERROR   ] = color_orange,
	[LOG_PRIORITY_CRITICAL] = color_red,
}
M.history = {}

local receivers = {}
function M.addReceiver( callback--[[(type, priority, message)]] )
	table.insert( receivers, callback )
end
function M.removeReceiver( receiver )
	for k, v in pairs( receivers ) do
		if v == receiver then
			table.remove( receivers, k )
			break
		end
	end
end
function M.setPriority( category, priority )
	if not priority then
		sdl.LogSetAllPriority( category )
	else
		sdl.LogSetPriority( category, priority )
	end
end
function M.log( category, priority, str, ... )
	sdl.LogMessage( category, priority, tostring(str):format( ... ) )

end

for k, v in pairs( M.categories ) do--M.appInfo, M.appWarn, etc
	for k2, v2 in pairs( M.priorities ) do
		M[ v .. v2:sub(1,1):upper() .. v2:sub(2) ] = function( str, ... )
			M.log( k, k2, str, ... )
		end
	end
end
local ffi=require'ffi'
local oprint=print
local function callback( _, category, priority, message )
	message = ffi.string( message )
    if M.history then table.insert(M.history,{category,priority,message}) end
	for i, v in ipairs( receivers ) do
		local suc, err = pcall( v, category, priority, message )
		if not suc then
			M.removeReceiver( v )
			M.systemError( "Logger was removed due to an error: %s", err )
            if i == 1 then io.write("Logger was removed due to an error: %s", err) end
		end
	end
end
local outCallback, outUD = ffi.new("SDL_LogOutputFunction[1]"), ffi.new("void*[1]")
local last = sdl.LogGetOutputFunction(outCallback, outUD)
fickle.atexit(function()
	--sdl.LogSetOutputFunction(outCallback[0], outUD[0])
	sdl.LogSetOutputFunction(nil,nil)--todo actually cleanup
end)
sdl.LogSetOutputFunction( callback, nil )
function print( ... )
	local str = ''
	local vararg = {...}
	for i = 1, #vararg do str = str .. tostring( vararg[ i ] ) .. ' ' end
	M.log( LOG_CATEGORY_APPLICATION, LOG_PRIORITY_DEBUG, str )
end

M.addReceiver( function( category, priority, message )
    if jit.os == 'Windows' then
        io.write( '[' .. M.categories[category] .. ']' .. (priority ~= LOG_PRIORITY_INFO and M.priorities[ priority ] or '') .. ': ' .. message .. '\n' )
    else
        io.write( '[' .. M.colors[priority]:ANSI() .. M.categories[category] .. color_white:ANSI() .. ']' .. ': ' .. message .. '\n' )
    end
end )

M.setPriority( LOG_PRIORITY_VERBOSE )

return M
