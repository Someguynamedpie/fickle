local platform = class( 'platform.Base' )
--gets the current working directory
function platform:getCWD() return '' end
--converts relative path to full pathname
function platform:resolvePath(path) return path end

return require( "platform." .. jit.os:lower() )