local lang = {}
local L = {}
function lang.translate( key, ... )
	return L[key]:format( ... )
end
function lang.loadPO( path )
	
end