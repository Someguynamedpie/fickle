local M = {}
local sdl = require'lib.sdl2'

local binds = {}

function M.getKeyForName( name )
	local suc, err = pcall(function() return sdl['KEY_'..name] end)
	if not suc then return end
	return err
end

function M.bind( key, command )
	key = M.getKeyForName( key )
	if not key then return false end
	binds[ key ] = command
	return true
end

local console = require'console'

function M.onKeyDown( key )
	if( binds[ key ] ) then
		console.execute( binds[ key ] )
		return true
	end
end

function M.onKeyUp( key )
	if( binds[ key ] and binds[ key ]:sub(1,1) == '+' ) then
		console.execute( "-" .. binds[ key ]:sub(2) )
		return true
	end
end

console.add( "bind", function(ply, _, args)
	if not args[1] then print "Usage: bind <key> <command>" end
	if not args[2] then
		local n = M.getKeyForName( args[1] )
		if not n then print( "Unknown key " .. n ) return end
		print( args[1] .. " is bound to \"" .. (binds[n] or "<unbound>") .. '"' )
		return
	end
	local suc = M.bind( args[1], args[2] )
	if not suc then return "Unknown key " .. args[1] end
end, "Binds a key to a command." )



return M