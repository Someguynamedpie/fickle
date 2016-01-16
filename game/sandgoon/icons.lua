local M = {}
local dmi=require'video.dmi'
local cache = {}
function M.loadDMI( path,log )
	if cache[ path ] then return cache[ path ] end
	print( "Loading " .. path)
	local floor = Texture( path )--'icons/turf/space.dmi'
	dmi.load(floor,log)
	cache[ path ] = floor
	return floor
end
return M
