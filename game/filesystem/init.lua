local M = {}
local path = require( 'filesystem.path' )
local mounted = {}
local max = math.max
--mounts a filesystem at point(a path in the VFS)
function M.mount( point, interface )
	point = (point:sub( 1, 1 ) == '/' and '/' or '') .. path.resolve( point ) .. (point:sub( max(#point,2), max(#point,2) ) == '/' and '/' or '')
	mounted[ point ] = mounted[ point ] or {}
	table.insert( mounted[ point ], interface )
end

function table.hasValue( tbl, val ) for k, v in pairs( tbl ) do if v == val then return true end end end

local rootResolver = {''}
function M.getMountedAt( point )--TODO: Cleanup
	local ret = {}
	local pnt = path.resolve( point )
	local resolved = path.getResolved( point, true )
	if #resolved == 0 then resolved = rootResolver end
	local fullPath = "/"
	for k, v in ipairs( resolved ) do
		fullPath = fullPath .. v
		for k, v in pairs( mounted ) do
			if( fullPath:sub( 1, #k ) == k ) then
				for i = 1, #v do
					ret[ v[i] ] = pnt:sub( #k )
				end
			end
		end
	end
	return ret
end

function M.exists( path )
	for k, v in pairs( M.getMountedAt( path ) ) do
		local ret = k:exists( v )
		if ret then return true end
	end
    return false
end

--lists files and folders in the point folder.
function M.open( pos, mode )
	for k, v in pairs( M.getMountedAt( pos ) ) do
		local ret = k:open( v, mode )
		if ret then return ret end
	end
end

local basefs = class( 'fs.BaseFS' )
function basefs:open( path, mode )
	return false
end
function basefs:remove( path )
	return false
end
function basefs:exists( path )
	return false
end

local osfs = require'filesystem.os'

local sysfs = class( 'fs.SysFS', basefs )
function sysfs:open( path, mode )
	return io.open( path, mode )
end
function sysfs:exists( path )
	return osfs.exists( path )
end
function sysfs:remove( path )
	return os.remove( path )
end

M.mount( "/", sysfs:new() )

return M


