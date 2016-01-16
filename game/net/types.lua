_R=debug.getregistry()
_R.Buffer = {}
_R.Buffer.__index = _R.Buffer

function Buffer( str )
	return setmetatable( { buffer = str or "", position = 1 }, _R.Buffer )
end

function _R.Buffer:GetBuffer()
	return self.buffer
end

function _R.Buffer:GetRaw()
	return self.buffer
end

function _R.Buffer:__len()
	return string.len( self.buffer )
end

function _R.Buffer:Length()
	return string.len( self.buffer )
end

function _R.Buffer:Write( str )
	local before = string.sub( self.buffer, 0, self.position - 1 ) or ""
	local after = string.sub( self.buffer, self.position  ) or ""
	self.buffer = before .. str .. after
	self.position = self.position + string.len( str )
	return self
end

function _R.Buffer:WriteByte( byte )
	self:WriteChar( string.char( byte ) )
	return self
end

function _R.Buffer:WriteChar( char )
	self:Write( char )
	return self
end

function _R.Buffer:ReadChar()
	local ret = string.sub( self.buffer, self.position, self.position )
	self.position = self.position + 1
	return ret
end

function _R.Buffer:ReadByte()
	return string.byte( self:ReadChar() )
end

function _R.Buffer:WriteInt( int )
	self:WriteByte( bit.band(bit.rshift(int,24),0xFF) )
	self:WriteByte( bit.band(bit.rshift(int,16),0xFF) )
	self:WriteByte( bit.band(bit.rshift(int,8),0xFF) )
	self:WriteByte( bit.band(int,0xFF) )
	return self
end

function _R.Buffer:ReadInt()
	return bit.lshift( self:ReadByte(), 24 ) + bit.lshift( self:ReadByte(), 16 ) + bit.lshift( self:ReadByte(), 8 ) + bit.lshift( self:ReadByte(), 0 )
end

function _R.Buffer:WriteFloat( float )
	if float == 0 then
		self:WriteByte( 0x00 )
		self:WriteByte( 0x00 )
		self:WriteByte( 0x00 )
		self:WriteByte( 0x00 )
	elseif float ~= float then
		self:WriteByte( 0xFF )
		self:WriteByte( 0xFF )
		self:WriteByte( 0xFF )
		self:WriteByte( 0xFF )
	else
		local sign = 0x00
		if float < 0 then
			sign = 0x80
			float = -float
		end
		local mantissa, exponent = math.frexp( float )
		exponent = exponent + 0x7F
		if exponent <= 0 then
			mantissa = math.ldexp(mantissa, exponent - 1)
			exponent = 0
		elseif exponent > 0 then
			if exponent >= 0xFF then
				self:WriteByte( sign + 0x7F )
				self:WriteByte( 0x80 )
				self:WriteByte( 0x00 )
				self:WriteByte( 0x00 )
				return
			elseif exponent == 1 then
				exponent = 0
			else
				mantissa = mantissa * 2 - 1
				exponent = exponent - 1
			end
		end
		mantissa = math.floor(math.ldexp(mantissa, 23) + 0.5)

		self:WriteByte( sign + math.floor(exponent / 2) )
		self:WriteByte( (exponent % 2) * 0x80 + math.floor(mantissa / 0x10000) )
		self:WriteByte( math.floor(mantissa / 0x100) % 0x100 )
		self:WriteByte( mantissa % 0x100 )
	end
	return self
end

function _R.Buffer:ReadFloat()
	local b1, b2, b3, b4 = self:ReadByte(), self:ReadByte(), self:ReadByte(), self:ReadByte()
	local exponent = (b1 % 0x80) * 0x02 + math.floor(b2 / 0x80)
	local mantissa = math.ldexp(((b2 % 0x80) * 0x100 + b3) * 0x100 + b4, -23)
	if exponent == 0xFF then
		if mantissa > 0 then
			return 0 / 0
		else
			mantissa = math.huge
			exponent = 0x7F
		end
	elseif exponent > 0 then
		mantissa = mantissa + 1
	else
		exponent = exponent + 1
	end
	if b1 >= 0x80 then
		mantissa = -mantissa
	end
	return math.ldexp(mantissa, exponent - 0x7F)
end

function _R.Buffer:WriteShort( short )
	self:WriteByte( bit.band(bit.rshift(short,8),0xFF) )
	self:WriteByte( bit.band(short,0xFF) )
	return self
end

function _R.Buffer:ReadShort()
	return bit.lshift( self:ReadByte(), 8 ) + bit.lshift( self:ReadByte(), 0 )
end

function _R.Buffer:WriteString( str )
	self:WriteShort( #str )
	self:Write( str )
	return self
end

function _R.Buffer:ReadString()
	local len = self:ReadShort() - 1
	local ret = string.sub( self.buffer, self.position, self.position + len )
	self.position = self.position + len + 1
	return ret
end

function _R.Buffer:Read( len )
	len = len - 1
	local ret = string.sub( self.buffer, self.position, self.position + len )
	self.position = self.position + len + 1
	return ret
end
function _R.Buffer:WriteColor( col )
	self:WriteByte( col.r )
	self:WriteByte( col.g )
	self:WriteByte( col.b )
	return self
end

function _R.Buffer:ReadColor()
	return Color( self:ReadByte(), self:ReadByte(), self:ReadByte() )
end

function _R.Buffer:Seek( pos )
	self.position = pos
end

function _R.Buffer:Next()
	local nxt = self.position + 1
	return string.byte( string.sub( self.buffer, nxt, nxt ) )
end

function _R.Buffer:SendTo( sock )
	return sock:send( self:GetRaw() )
end

function _R.Buffer:WriteTable( tbl )
	for k, v in pairs( tbl ) do
		self:WriteType( k )
		self:WriteType( v )
	end
	self:WriteByte( 0 )
	return self
end

function _R.Buffer:ReadTable()
	local tbl = {}
	
	while true do
		local t = self:ReadByte()
		if ( t == 0 ) then return tbl end
		local k = self:ReadType( t )
	
		local t = self:ReadByte()
		if ( t == 0 ) then return tbl end
		local v = self:ReadType( t )
		
		tbl[ k ] = v
	end
end


--todo: optimize
NET_BYTE     = 0-- 8 bit byte
NET_BOOL     = 1 -- 8 bit boolean
NET_SHORT    = 2--16 bit integer [-32767..32767]
--NET_USHORT   = 3--16 bit uinteger[0..65535]
NET_INT      = 4--32 bit integer [-2147483647..2147483647]
--NET_UINT     = 5--32 bit uinteger[0..4294967296]
NET_FLOAT    = 6--32 bit float
NET_ENTITY   = 7--32 bit entity
NET_STRING   = 8--variable length string

local types = {
	read = {
		[NET_BOOL] =  _R.Buffer.ReadBool,
		[NET_BYTE] =  _R.Buffer.ReadByte,
		[NET_SHORT] = _R.Buffer.ReadShort,
		[NET_INT] =   _R.Buffer.ReadInt,
		[NET_FLOAT] = _R.Buffer.ReadFloat,
		[NET_STRING] =_R.Buffer.ReadString
	},
	write = {
		[NET_BOOL] =  _R.Buffer.WriteBool,
		[NET_BYTE] =  _R.Buffer.WriteByte,
		[NET_SHORT] = _R.Buffer.WriteShort,
		[NET_INT] =   _R.Buffer.WriteInt,
		[NET_FLOAT] = _R.Buffer.WriteFloat,
		[NET_STRING] =_R.Buffer.WriteString
	}
}

function _R.Buffer:WriteType( type, data )
	types.write[ type ]( self, data )
end
function _R.Buffer:ReadType( type, data )
	return types.read[ type ]( self )
end
