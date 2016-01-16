local M = {}

local ffi = require'ffi'
ffi.cdef[[
	int GetFileAttributesA( const char* path );
]]

function M.exists( path )
	return ffi.C.GetFileAttributesA( path ) ~= -1
end
return M