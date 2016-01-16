local ffi=require'ffi'
NET_PROTOCOL_VERSION = 'FICKL'
net.messages = {
	server = {},
	client = {}
}
NETCHAN_RELIABLE   = 0
NETCHAN_UNRELIABLE = 1
NETCHAN_FILEXFER   = 3

local roles = {
	['C2S'] = {server = true, client = false},
	['S2C'] = {server = false, client = true},
	['NET'] = {server = true, client = true}
}
local id = 0
function net.definePacket( name, structure, server, client, reliable, xfer )
	if( id >= 0xFF ) then
		error( "Exceeded current packet limit." )
	end
	local role = roles[ name:sub( 1, 3 ) ]
	local chan = NETCHAN_RELIABLE
	print("Registered ", name, chan, role.server, role.client, id, role.client and "SENT TO CLIENT", role.server and "SENT TO SERVER" )
	if not role then error( "INVALID ROLE " .. role:sub(1,3) ) end
	if not reliable then chan = NETCHAN_UNRELIABLE elseif xfer then chan = NETCHAN_FILEXFER end
	if role.server then net.messages.server[ id ] = {structure = structure, callback = server, name = name, channel = chan} end
	if role.client then net.messages.client[ id ] = {structure = structure, callback = role.server and client or server, name = name, channel = chan } end
	if not role.server and not role.client then error"??" end
	_G[ name ] = id
	id = id + 1
end
function net.getPacketSpec( id, role ) return net.messages[ role ][ id ] end

function net.processClientPacket( client, data, len )
	local buffer = Buffer( ffi.string( data, len ) )
	local header = buffer:Read( 5 )
	if header ~= NET_PROTOCOL_VERSION then
		client:kick( "Mismatched Protocol" )
		return
	end

	local pid = buffer:ReadByte()
	local data = {}
	local spec = net.getPacketSpec( pid, 'server' )
	for k, v in ipairs( spec.structure ) do
		data[ v[1] ] = buffer:ReadType( v[2] )
	end
	spec.callback( client, data, buffer )
end
function net.processServerPacket( data, len )
	local buffer = Buffer( ffi.string( data, len ) )
	local header = buffer:Read( 5 )
	if header ~= NET_PROTOCOL_VERSION then
		net.disconnect( "Mismatched Protocol" )
		print('mismatch got ',header, ' expected ', NET_PROTOCOL_VERSION)
		return
	end

	local pid = buffer:ReadByte()
	local data = {}
	local spec = net.getPacketSpec( pid, 'client' )
	for k, v in ipairs( spec.structure ) do
		data[ v[1] ] = buffer:ReadType( v[2] )
	end
	spec.callback( data, buffer )
end

net.definePacket( "NET_Disconnect", {{'reason',NET_STRING}}, function( client, data )
	client.disconnectReason = data.reason
end, function( data )
	net.disconnectReason = data.reason
end, true )

--net.definePacket( "NET_UserMessage", 
--[[
net.definePacket( "NET_FileRequest", {{'file', NET_STRING}, {'crc', NET_INTEGER}}, function( client, data )
	if( data.path:find'%.%.' ) then print(":O") return end
	--todo!
end, function( data )--todo!
end, nil, true )--]]
	
