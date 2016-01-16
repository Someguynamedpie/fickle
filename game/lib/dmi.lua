local ffi = require'ffi'
ffi.cdef[[
typedef struct {
	union {
		struct { char a; char b; char c; char d; };
		int integer;
	};
} intconv;
]]
local zlib = require'lib.zlib'
local intconv = ffi.new('intconv')
local M = {}
function M.readDMI( path )
	local dmi,err = io.open( 'textures/' .. path, 'rb' )
	if not dmi then error(path..'|'..err) end
	local data = dmi:read(4096)
	local at = data:find('zTXt')
	if data:find('zTXt') then dmi:seek('set',at-1) end--hack
	--print("Found DMI",path,'at',tostring(data:find('zTXt')))
	for i = 1, 2 do
		local data=dmi:read(4)
		if not data then return false end
		--print(data:gsub("[^%g]","."):gsub('%%','.'))
		if data == 'zTXt' then
			local chunk = dmi:seek('cur', 0) - 8
			dmi:seek( 'cur', -8 )
			local a, b, c, d = dmi:read( 4 ):byte(1,4)
			intconv.a = d intconv.b = c intconv.c = b intconv.d = a
			dmi:read(4)
			local dst = ffi.new( 'uint8_t[?]', 0xFFFF )
			local buflen = ffi.new( 'unsigned long[1]', 0xFFFF )

			local compressed = dmi:read( intconv.integer )
			local null = compressed:find( '\x00' ) + 2
			compressed = compressed:sub( null )

			assert( zlib.uncompress( dst, buflen, compressed, #compressed ) == 0 )
			dmi:close()

			return M.parse( ffi.string( dst, buflen[0] ) )
		end
	end
	dmi:close()
	return false
end

function M.parse( dmi )
	dmi = dmi:sub( select( 2, dmi:find'\n' ) + 1 )
	local groups = {}
	local group
	for key, value in dmi:gmatch( '(.-) = (.-)\n' ) do
		if( key:sub( 1, 1 ) == '\t' ) then
			group.keys[ key:match("%S+") ] = tonumber(value) or value
		elseif key:sub( 1, 1 ) ~= '#' then
			group = {key = key:match("%S+"), value = value:find('"') and value:sub(2, -2) or (tonumber(value) or value), keys = {}}
			table.insert( groups, group )
		end
	end
	return groups
end
return M
