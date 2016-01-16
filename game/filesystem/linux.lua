local M = {}

local ffi = require'ffi'
ffi.cdef[[
	enum {
		F_OK = 0,
		X_OK = 1,
		W_OK = 2,
		R_OK = 4
	};
	int access( const char* path, int amode );
]]

function M.exists( path )
	return ffi.C.access( path, ffi.C.F_OK ) == 1
end
return M