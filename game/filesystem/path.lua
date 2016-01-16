local M = {}
--splits directory by dir seperators
function M.split( tree )
	local ret = {}
	for entry in ('/'..tree..'/'):gmatch( '(.-)[/\\]+' ) do
		if entry ~= '' then
			table.insert( ret, entry )
		end
	end
	return ret
end
--resolves dots in paths(a/b/c/../e to a/b/e)
function M.resolve( path, includeSlash )
	return table.concat( M.getResolved( path, includeSlash ), '/' )
end
local slashy = {''}
function M.getResolved( path, includeSlash )
	local split = M.split( path )
	local i = 1
	while i <= #split and i > 0 do
		local v = split[i]
		if not v then break end
		if includeSlash then split[i] = split[i] .. (i == #split and (path:sub(#path,#path) == '/' and '/' or '') or '/') end
		if( v == '.' ) then
			table.remove( split, i )
		elseif( v == '..' ) then
			table.remove( split, i )
			table.remove( split, i - 1 )
			i = i - 1
		else
			i = i + 1
		end
	end
	return split
end

function M.hasExtension( path, extensions )
	if( type( extensions ) == 'string' ) then
		return path:find( "%." .. extensions .. "$" )
	end
	for k, v in pairs( extensions ) do
		if path:find( "%." .. extensions .. "$" ) then
			return true
		end
	end
	return false
end

return M