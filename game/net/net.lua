local enet = require'lib.enet'
net = {}
require( 'net.types' )
require( "net.messages" )
function net.init()
	if enet.initialize() ~= 0 then
		error( "Failed  to initialize ENet" )
	end
end
function net.OnPreConnect() end
if not DEDICATED then
	function net.connect( ip, port )
		net.OnPreConnect()
		port = port or 7777
		ip = ip or 'localhost'
		local address = ffi.new( 'ENetAddress[1]' )
		enet.address_set_host( address[0], ip )
		address[0].port = port
		
		local host = enet.host_create( nil, 1, 3, 0, 0 )
		if host == ffi.null then error( "Failed to create client host!" ) end
		print( "Connecting to peer...")
		local peer = enet.host_connect( host, address, 3, 0 )
		if peer == ffi.null then error( "Failed to create client peer!" ) end
		enet.peer_timeout( peer, 2000, 1800, 2200 )
		net.client = {peer = peer, host = host}
	end
	function net.isConnected()
		return net.client ~= nil
	end
end

--local ffi=require'ffi' ffi.cdef[[int WSAGetLastError();]] local --ads = ffi.load'Ws2_32.dll'
function net.host( ip, port, maxplayers )
	local address = ffi.new( 'ENetAddress[1]' )
	if ip == '*' then
		address[0].host = enet.HOST_ANY
	else
		enet.address_set_host( address, ip )
	end
	address[0].port = port or 7777
	local server = enet.host_create( address, maxplayers or 8, 3, 0, 0 )
	if server == ffi.null then
		error( "Failed to create ENet server!" )
	end
	net.server = server
	net.clients = {}
	
	return true
end
function net.peerToClient( peer )
	for k,v in pairs( net.clients ) do
		if( v.peer == peer ) then
			return v
		end
	end
end

function net.sendraw( buffer, channel, peer )
	local packet = enet.packet_create( buffer.buffer, #buffer.buffer, channel ~= NETCHAN_UNRELIABLE and enet.PACKET_FLAG_RELIABLE or 0 )
	enet.peer_send( peer, channel, packet )
	
end
function net.send( pid, data, peer )
	local packet = Buffer()
	local spec = net.getPacketSpec( pid, net.client and 'server' or 'client' )
	
	if not spec then error( "INVALID PACKET TYPE " .. pid .. " FOR " .. (peer == net.server and 'server' or 'client') ) end
	packet:Write( NET_PROTOCOL_VERSION )
	packet:WriteByte( pid )
	for k, v in ipairs( spec.structure ) do
		packet:WriteType( v[2], data[ v[1] ] )
	end
	
	net.sendraw( packet, spec.channel, peer )
end
function net.start( pid, data )
	local packet = Buffer()
	local spec = net.getPacketSpec( pid, 'client' )
	
	packet:Write( NET_PROTOCOL_VERSION )
	packet:WriteByte( pid )
	for k, v in ipairs( spec.structure ) do
		packet:WriteType( v[2], data[ v[1] ] )
	end
	packet.spec = spec
	return packet
end
function net.finish( packet, tgt, exclude )
	if net.isHosting() and not tgt then
		for k, v in pairs( net.clients ) do
			if v ~= exclude then
				net.sendraw( packet, packet.spec.channel, v.peer )
			end
		end
	elseif tgt then
		net.sendraw( packet, packet.spec.channel, tgt.peer )
	elseif net.isConnected() then
		net.sendraw( packet, packet.spec.channel, net.client.peer )
	end
end
function net.broadcast( pid, data )
	local packet = Buffer()
	local spec = net.getPacketSpec( pid, 'client' )
	
	packet:Write( NET_PROTOCOL_VERSION )
	packet:WriteByte( pid )
	for k, v in ipairs( spec.structure ) do
		packet:WriteType( v[2], data[ v[1] ] )
	end
	for k, v in pairs( net.clients ) do
		net.sendraw( packet, spec.channel, v.peer )
	end
end
function net.sendToServer( pid, data ) net.send( pid, data, net.client.peer ) end

local cmeta = {} cmeta.__index = cmeta
function cmeta:send( pid, data )
	net.send( pid, data, self.peer )
end
function cmeta:kick( rsn )
	self:send( NET_Disconnect, {reason = rsn} )
	enet.peer_ping( self.peer )--force disconnect_later to wait for ping reply, and along with it the disconnect message
	enet.peer_disconnect_later( self.peer, 0 )
end
function cmeta:drop()
	enet.peer_disconnect_now( self.peer, 0 )
	net.onClientDisconnected( self )
end
local netevent = ffi.new( 'ENetEvent[1]' )
function net.OnClientAccepted(c) end
function net.onClientDisconnected(c) end
function net.pollServer()
	while enet.host_service( net.server, netevent, 0 ) > 0 do
		local event = netevent[ 0 ]
		if event.type == enet.EVENT_TYPE_CONNECT then
			if net.disconnecting then setmetatable( { peer = event.peer }, cmeta ):kick( "Server shutting down." ) else
				local cli = setmetatable( { peer = event.peer }, cmeta )
				print( ("Client connection attempt.") )
				table.insert( net.clients, cli )
				net.OnClientAccepted( cli )
			end
			enet.peer_timeout( event.peer, 2000, 1800, 2200 )
			
		elseif event.type == enet.EVENT_TYPE_RECEIVE and not net.disconnecting then
			net.processClientPacket( net.peerToClient( event.peer ), event.packet.data, event.packet.dataLength )
		elseif event.type == enet.EVENT_TYPE_DISCONNECT then
			if not net.disconnecting then
				print( ("Client disconnected! ") .. ((net.peerToClient( event.peer ) and net.peerToClient( event.peer ).disconnectReason or nil) or "No reason given" ) )
			end
			net.onClientDisconnected( net.peerToClient( event.peer ) )
		end
	end
end
function net.OnConnected() end
if not DEDICATED then
	function net.onServerDisconnected()
		net.client = nil
		game.setState( STATE_MENU, net.disconnectReason or "Unknown Reason" )
	end
	function net.pollClient()
		while enet.host_service( net.client.host, netevent, 0 ) > 0 do
			local event = netevent[ 0 ]
			if event.type == enet.EVENT_TYPE_CONNECT then
				print( ("Connected to Server!") )
				net.OnConnected()
				return
			elseif event.type == enet.EVENT_TYPE_RECEIVE then
				net.processServerPacket( event.packet.data, event.packet.dataLength )
			elseif event.type == enet.EVENT_TYPE_DISCONNECT then
				print( ("Disconnected from Server: ") .. (net.disconnectReason or 'No reason given') )
				net.onServerDisconnected( event.peer )
				net.disconnectReason = nil
				return
			end
		end
	end
	function net.onServerDisconnected( reason )
		enet.host_destroy( net.client.host )
		net.client = nil
		game.setState( "disconnected", {reason = "Disconnected"} )
	end
end
function net.waitUntilDisconnect()
	if not DEDICATED then
		timeLeft = sdl.GetTicks() + 2000
		while net.isConnected() and sdl.GetTicks() < timeLeft do net.pollClient() sdl.Delay(100) end
	end
end
function net.isHosting()
	return net.server ~= nil
end
function net.onClientDisconnected( peer )
	for k,v in pairs(net.clients) do
		if( v == peer ) then table.remove( net.clients, k ) break end
	end
	--todo
end
function net.disconnect(rsn)
	if net.isHosting() then
		for k, v in pairs( net.clients ) do
			v:kick( "Server shutting down." )
		end
		timeLeft = sdl.GetTicks() + 2000
		net.disconnecting = true
		while timeLeft > sdl.GetTicks() and #net.clients ~= 0 do net.pollServer() sdl.Delay( 50 ) end
		enet.host_destroy( net.server )
		net.disconnecting = false
		net.server = nil
		net.clients = nil
		if not DEDICATED then fickle.exit( ) end
	elseif not DEDICATED and net.isConnected() then
		net.sendToServer( NET_Disconnect, { reason = rsn or "Disconnect by User." } )
		enet.peer_ping( net.client.peer )--force disconnect_later to wait for ping reply, and along with it the disconnect message
		enet.peer_disconnect_later( net.client.peer, 1 )
		
	end
end
function net.poll()
	if not DEDICATED and net.isConnected() then
		net.pollClient()
	end
	if net.isHosting() then
		net.pollServer()
	end
end
fickle.atexit( function()
	net.disconnect( "Disconnect by User" )
	net.waitUntilDisconnect()
end )
