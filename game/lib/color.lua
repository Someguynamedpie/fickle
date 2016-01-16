local ANSI_ESCAPE = string.char(27)
local _R = debug.getregistry()

function unpackcolor( col ) -- Unpack a color
	return col.r, col.g, col.b, col.a
end

function ColorDistance( col1, col2 )
	local r, g, b = unpackcolor( col1 )
	local s, h, c = unpackcolor( col2 )
	r = r - s
	g = g - h
	b = b - c
	return r * r + g * g + b * b
end

function ColorVector( col )
	return Vector( col.r / 255, col.g / 255, col.b / 255 )
end

function HexColor( hex ) -- Creates a color using a Hex value, 0xFFFFFF
	return Color( bit.band(bit.rshift(hex,16),0xFF), bit.band(bit.rshift(hex,8),0xFF), bit.band(bit.rshift(hex,0),0xFF) )
end

function ColorHex( col ) -- Convets a color to hex, wouldn't be needed if this metatable was default.. Some old Color tables still exist..
	if(type(col)=="number") then return col end
	return bit.lshift(col.r,16) + bit.lshift(col.g,8) + bit.lshift(col.b,0)
end

_R.Color = {}
_R.Color.__index = _R.Color

function Color( r, g, b, a )
	return setmetatable( {
		r = math.min(tonumber(r or 255), 255 ),
		g = math.min(tonumber(g or 255), 255),
		b = math.min(tonumber(b or 255), 255),
		a = math.min(tonumber(a or 255), 255)
	}, _R.Color )
end

function _R.Color:__tostring()
	return string.format( "Color [%i, %i, %i, %i][#%X]", self.r, self.g, self.b, self.a, self:hex() )
end

function _R.Color:__add( col )
	return Color(math.Clamp(self.r + col.r, 0, 255), math.Clamp(self.g + col.g, 0, 255), math.Clamp(self.b + col.b, 0, 255))
end

function _R.Color:__mul( col )
	return Color(((self.r / 255) * (col.r / 255)) * 255, ((self.g / 255) * (col.g / 255)) * 255, ((self.b / 255) * (col.b / 255)) * 255)
end

function _R.Color:__eq( col )
	return self.r == col.r and self.g == col.g and self.b == col.b and self.a == col.a
end

function _R.Color:fadeTo( col, frac )
	local faded = Color( 255, 255, 255 )
	faded.r = ( self.r * ( 1 - frac ) ) + col.r * frac
	faded.g = ( self.g * ( 1 - frac ) ) + col.g * frac
	faded.b = ( self.b * ( 1 - frac ) ) + col.b * frac
	faded.a = ( self.a * ( 1 - frac ) ) + col.a * frac
	return faded
end

function _R.Color:hex()
	return ColorHex( self )
end

function _R.Color:distance( col )
	return ColorDistance( self, col )
end

local ANSIColors = {
	[ ANSI_ESCAPE .. "[30m" ] = Color(0,0,0), -- Black
	[ ANSI_ESCAPE .. "[31m" ] = Color(187,0,0), -- Red
	[ ANSI_ESCAPE .. "[32m" ] = Color(0,187,0), -- Green
	[ ANSI_ESCAPE .. "[33m" ] = Color(187,187,0), -- Yellow
	[ ANSI_ESCAPE .. "[34m" ] = Color(0,0,187), -- Blue
	[ ANSI_ESCAPE .. "[35m" ] = Color(187,0,187), -- Purple
	[ ANSI_ESCAPE .. "[36m" ] = Color(0,187,187), -- Cyan
	[ ANSI_ESCAPE .. "[37m" ] = Color(187,187,187), -- Gray

	[ ANSI_ESCAPE .. "[1;30m" ] = Color(85,85,85), -- Dark Gray
	[ ANSI_ESCAPE .. "[1;31m" ] = Color(255,85,85), -- Light Red
	[ ANSI_ESCAPE .. "[1;32m" ] = Color(85,255,85), -- Light Green
	[ ANSI_ESCAPE .. "[1;33m" ] = Color(255,255,85), -- Light Yellow
	[ ANSI_ESCAPE .. "[1;34m" ] = Color(85,85,255), -- Light Blue
	[ ANSI_ESCAPE .. "[1;35m" ] = Color(255,85,255), -- Magenta
	[ ANSI_ESCAPE .. "[1;36m" ] = Color(85,255,255), -- Cyan
	[ ANSI_ESCAPE .. "[1;37m" ] = Color(255,255,255), -- White
}

function ColorANSI( self )
	local ret = ANSI_ESCAPE .. "[37m"
	local lastDist

	for str,col in pairs( ANSIColors ) do
		local dist = self:distance( col )
		if not lastDist or dist < lastDist then
			ret = str
			lastDist = dist
		end
	end

	return ret
end

function _R.Color:brighter( factor ) factor = factor or .7
	local r, g, b = self.r, self.g, self.b

	local n = 1/(1-factor)
	if r == 0 and g == 0 and b == 0 then return Color( n, n, n ) end

	return Color( math.min( r/factor, 255 ), math.min( g/factor, 255 ), math.min( b/factor, 255 ) )
end
function _R.Color:darker( factor ) factor = factor or .7
	local r, g, b = self.r, self.g, self.b

	local n = 1/(factor)
	if r == 0 and g == 0 and b == 0 then return Color( n, n, n ) end

	return Color( math.min( r/factor, 255 ), math.min( g/factor, 255 ), math.min( b/factor, 255 ) )
end
function _R.Color:ANSI()
	return ColorANSI( self )
end

color_blank = Color( 0, 0, 0, 0 )
color_white = Color( 255, 255, 255 )
color_lightgray = Color( 200, 200, 200 )
color_black = Color( 0, 0, 0 )
color_red = Color( 237, 28, 36 )
color_green = Color( 34, 177, 76 )
color_blue = Color( 0, 162, 232 )
color_entity = Color( 151, 211, 255 )
color_pink = Color( 255, 128, 128 )
color_hotpink = Color( 255, 105, 180 )
color_orange = Color( 255, 126, 0 )
color_gray = Color( 126, 126, 126 )
color_darkgray = Color( 60, 60, 60 )
color_skyblue = Color( 135, 206, 235 )
