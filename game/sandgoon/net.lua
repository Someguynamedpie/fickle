local game = require( 'sandgoon.game' )
local map  = require( 'sandgoon.level' )
net.definePacket( "S2C_MapSetup", {{'width',NET_SHORT}, {'height',NET_SHORT}, {'depth',NET_SHORT}}, function( data )
	game.setLevel( map.new( data.width, data.height, data.depth ) )
	game.roundState = ROUNDSTATE_PREGAME-- New map? New game!
end )

--[[function net.OnClientAccepted( c )
	for k, v in pairs( level.entities ) do
		c:send( S2C_NewEntity, {type = v.typeid, x = v.x, y = v.y, id = v.id or 0} )
	end
	local them = level:newEntity( "/obj/mob/human" )
	c.mob = them
	for k, v in pairs( level.entities ) do
		if( v.path == "/obj/spawnpoint" ) then
			them:setpos( v.x, v.y, v.z )
			break
		end
	end
    --c:send( S2C_NewEntity, {path = them.path, x = them.x, y = them.y, id = them.id or 0} )
	c:send( S2C_EyeAttach, {id=them.id} )
end

function net.OnConnected()
	level:clearEntities()
	print("PRECONNECT ENTS CLEARED")
end

function net.onClientDisconnected( client )
	client.mob:remove()
end

net.definePacket( "S2C_NewEntity", {{'type',NET_INT}, {'x', NET_INT}, {'y', NET_INT}, {'id', NET_INT}}, function(data)
    
	local ent = level:newEntity( data.type, true )
	
	ent:setpos( data.x, data.y, 1 )
	ent.id = data.id
	if( ent.id == ply ) then
		ply = ent
	end
end, nil, true )

net.definePacket( "S2C_EyeAttach", {{'id', NET_INT}}, function( data )
	ply = level:entByID( data.id ) or data.id
	print( "Attached to ", ply, ply.id, ply.x, ply.y )
end, nil, true )

net.definePacket( "S2C_EntPos", {{'id', NET_INT}, {'x', NET_INT}, {'y', NET_INT}, {'z', NET_INT}}, function( data )
	local ent = level:entByID( data.id )
	if ent then ent:setpos( data.x, data.y, data.z ) else print"???" end
end, nil, true )

net.definePacket( "S2C_EntRemove", {{'id', NET_INT}}, function( data )
	local ent = level:entByID( data.id )
	if ent then ent:remove() end
end, nil, true )

net.definePacket( "S2C_EntMove", {{'id', NET_INT}, {'x', NET_INT}, {'y', NET_INT}}, function( data )
	local ent = level:entByID( data.id )
	if not ent then
		print( "Got invalid entmove packet (" .. data.id .. ")" )
	else
		ent:Move( data.x, data.y, true, true )
	end
end, nil, true )

net.definePacket( "C2S_Move", {{'x', NET_INT}, {'y', NET_INT}}, function( client, data )
	local ent = client.mob
	ent:Move( data.x, data.y )
end, nil, true )

net.definePacket( "S2C_EntCommand", {{'id', NET_INT}, {'cmd', NET_BYTE}}, function( data, buffer )
	local ent = level:entByID( data.id )
    if not ent then return end
	if data.cmd == ECMD_FLICK_STATE then
		--flick w/o icon change
		ent:flick( buffer:ReadString(), nil, true )
	elseif data.cmd == ECMD_FLICK_ICONSTATE then
		--flick w/ icon change
		ent:flick( buffer:ReadString(), buffer:ReadString(), true )
	end
end, nil, true )

net.definePacket( "NET_ChatMessage", {{'message',NET_STRING}, {'id', NET_INT}}, function(client, data)
	client.mob:say( data.message )
end, function( data )
	level:entByID( data.id ):say( data.message, true )
end, true )

net.definePacket( "C2S_UserCommand", {{'buttons', NET_INT}}, function( client, data )
	
end, true )
]]--
