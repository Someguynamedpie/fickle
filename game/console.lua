local concommand = require('concommand')
local convar = require('convar')
local console = {}

local queue = {}
--adds a command string to the buffer to be executed next frame.
function console.execute( buffer )
	buffer = buffer:gsub("\r","") .. '\n'
	for line in buffer:gmatch( '[^\n]+' ) do
		table.insert( queue, line )
	end
end
--TODO: Clean up tokenizer.
function console.tokenizeArguments( str )
	local args = {}
	local quote = '["|\']'
	local escape = '\\'
	local inString = false
	local escapeNext = false
	local curToken = ""
	local argsRaw = ''
	
	local checkForComment = false

	for char in str:gmatch( "." ) do
		if( checkForComment and char == '/' ) then
			break
		end
		if( #args > 0 ) then argsRaw = argsRaw .. char end
		if( escapeNext ) then
			curToken = curToken .. char
			escapeNext = false
		else
			if( char:find( quote ) ) then
				if( inString ) then
					if( char == inString ) then
						curToken = curToken:trim()
						if( curToken ~= "" ) then
							table.insert( args, curToken )
						end
						inString = false
						curToken = ""
					else
						curToken = curToken .. char
					end
				else
					inString = char
					curToken = curToken:trim()
					if( curToken ~= "" ) then
						table.insert( args, curToken )
					end
					curToken = ""
				end
			elseif( not inString and char == " " ) then
				curToken = curToken:trim()
				if curToken:sub( 1, 1 ) == '$' and #args > 1 then
                    local cv = (console.getConvar( curToken:sub(2) ) or console.getConvar( curToken ))
					curToken = cv and cv.value or curToken
				end
				if( curToken ~= "" ) then
					table.insert( args, curToken )
				end
				curToken = ""
			elseif( char:find( escape ) ) then
				escapeNext = true
			elseif( char == '/' ) then
				checkForComment = true
			else
				curToken = curToken .. char
			end
		end
	end
	curToken = curToken:trim( )
	if( curToken ~= "" ) then
		table.insert( args, curToken )
	end
	return args, argsRaw
end

local operators = {
	['='] = function( var, params )
		if( type( var ) == 'string' ) then
			console.createConvar( var, params[1] or '', 'Console Scripting Variable' )
		else
			var:setValue( params[1] )
		end
	end,
	['+='] = function( var, params )
		var:setValue(
						( tonumber( params[1] ) and tonumber( var:getValue() ) )
						and ( tonumber( var:getValue() ) + tonumber( params[1]))
						or  ( tostring( var:getValue() ).. tostring( params[1]))
					)
	end,
}

local function printf( str, ... )
	print( str:format( ... ) )
end

function console.getCommandPlayer()
	--todo
end

local commands = {}
function console.getTable()
    return setmetatable({},{__index=commands})
end

function console.add(name, callback, help)
    commands[name] = {callback = callback, help = help, name = name}
end

function console.dispatch(ply, cmd, raw, args)
    if(commands[cmd]) then
        local ret = commands[cmd].callback(ply, cmd, args, raw)
        if ret == false then
            return false
        end
        return true
    end
end

local convars = {}
local cv = class('core.ConVar')
function cv:new(tbl)
    for k,v in pairs(tbl) do self[k] = v end
end
function cv:getValue() return self.value end
function cv:number() return tonumber( self.value ) end
function cv:setValue(s) self.value = tostring(s) end
function console.createConvar(name, default, help)
	local cvar = cv:new{value = default or '0', help = help, name = name}
    convars[name] = cvar
	return cvar
end

function console.getConvar(name)
    return convars[name]
end


local function processCommand( commandString )
	local split, raw = console.tokenizeArguments( commandString )
	
	local cmd = table.remove( split, 1 )
	if not cmd then return end
	if( cmd:sub( 1, 1 ) == '$' and split[1] and split[2] ) then
		local cvar = console.getConvar( cmd )
		if cvar or split[1] == '=' then
			local op = operators[ split[1] ]
			if not op then printf( "Invalid Console/Convar Operator: %s", split[1] ) else
				table.remove( split, 1 )
				op( cvar or cmd, split )--you're spying on me arent you --Andrew; lol
			end
		else
			printf( "No Convar by the name %q; set one by using %s = ...", cmd, cmd )
		end
	else
		local ret = console.dispatch( console.getCommandPlayer(), cmd, raw, split )
		if ret ~= false then
			if ret == nil and not console.getConvar( cmd ) then
				printf( "Unknown command or convar %q.", cmd )
			elseif ret == nil then
				console.getConvar(cmd):setValue(raw)
			end
		else
			printf( "Usage: %s", commands[cmd].help )
		end

	end
end

function console.executeImmediately( command )
	for line in command:gmatch( '(.+)\n?' ) do
		for cmd in line:gmatch( '(.+);?' ) do
			processCommand( cmd )
		end
	end
end

function console.update()
	if( #queue > 0 ) then
		for i, v in ipairs( queue ) do
			console.executeImmediately( v )
		end
		queue = {}
	end
end
console.add("echo", function(ply, _, args) print(unpack(args)) end, "Echos a string into the console.")
console.add("run_lua", function(ply, _, _, raw) print(pcall(loadstring(raw))) end, "Runs the luas.")
console.add("help", function(ply, _, args) if(not args[1]) then return false end local ret = commands[args[1]] if ret then print( args[1], ': ', ret.help ) else print('No command by that name.') end end, "Gives help and usage info for a command.")
local audio = require'audio'
console.add("volume", function( _, _, args ) if not tonumber( args[1] ) then print( "Current volume: ", audio.getVolume() ) return end audio.setVolume( tonumber(args[1]) ) end, "Sets global volume. I recommend staying from 0-1...")
return console
