local ffi=require'ffi'
ffi.cdef[[
int GetFullPathNameA( const char* path, int bufferLength, char* outBuffer, char* lpFilePart );
int GetCurrentDirectoryA( int size, char* out );
enum{
	MAX_PATH = 0x00000104
}]]
local platform = class( "platform.Windows", "platform.Base" )
local pathBuffer = ffi.new( 'char[MAX_PATH]' )
function platform:getCWD()
	if ffi.C.GetCurrentDirectory( ffi.C.MAX_PATH, pathBuffer ) ~= 0 then return nil end
	return ffi.string( pathBuffer )
end

function platform:resolvePath( path )
	if ffi.C.GetFullPathNameA( path, ffi.C.MAX_PATH, pathBuffer, nil ) ~= 0 then return nil end
	return ffi.string( pathBuffer )
end
