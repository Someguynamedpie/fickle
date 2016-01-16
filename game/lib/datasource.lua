InputStream = class( "InputStream" )

function InputStream:canSeek() return false end
--seek to an offset, in bytes
function InputStream:seek( offset ) return false end
--read len number of bytes into dest, return bytes read or -1 for EOF
function InputStream:read( dest, len ) return -1 end
--return number of bytes available for reading
function InputStream:available() return 0 end
--seek to beginning, if possible
function InputStream:rewind() return self:seek( 0 ) end


