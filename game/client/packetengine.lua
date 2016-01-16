require'buffer'

local M = {}
function M.new( pid ) local ret = Buffer() ret.pid = pid return ret end
function M.send( p )
	if not M.encryption or p.pid == 228 then
		p:Seek( 1 )
		p:WriteBShort( p.pid )
		p:WriteBShort( p:Length() - 2 )
		p:SendTo( M.socket )
	else
		
		p:Seek( 1 )
		p:WriteBShort( p.pid )
		local out = p.buffer:sub(1,2)
		local idx = 0
		local buf = p.buffer
		for i = 3, p:Length() do
			out = out .. string.char(buf:byte( i, i ) + ((bit.rshift( M.encryption, (bit.band( index, 0x1f))) + idx) % 0xFF))
			idx = buf:byte( i, i )
		end
		M.socket:send( out )
	end
end
function M.hello(ver, net, key, seq)
	local p = M.new( 1 )
	p:WriteInt( ver )
	p:WriteInt( net )
	p:WriteInt( key - (ver + (bit.lshift( net, 16 ) ) ) )
	p:WriteShort( seq )
	M.send( p )
end

function M.read()
	self.socket:settimeout( 0 )
	local id = self.socket:read( 3 )
	if id then
		local id, len = id:byte(1,1), bit.rshift( id:byte(2,2) ) + id:byte(3,3)
		
	end
end
return M