local icons = require'sandgoon.icons'.loadDMI

local function T(t) t.color = t.color or color_white t.TYPE = 'turf' return t end
local M = T{
	rng = 0,
	name="root",
	desc="nondescript turf",
	dense = false,
	opaque = false
}

function M:Enter(mob)
	if( not self.dense ) then
		if self.contents then
			for k, v in pairs( self.contents ) do
				v:Touch()
				if( v.dense ) then
					return false
				end
			end
		end
		return true
	else return false end
end

function M:isDense()
	if( self.dense ) then
		return true
	else
		if self.contents then
			for k, v in pairs( self.contents ) do
				if( v.dense ) then
					return true
				end
			end
		end
		return false
	end
end

function M:isOpaque()
	if( self.opaque ) then
		return true
	end
	if self.contents then
		for k, v in pairs( self.contents ) do
			if( v.opaque ) then
				return true
			end
		end
	end
	return false
end

M.unsimulated = T{name = "unsimulated"}
M.unsimulated.space = T{
	new = function(self)
		self.icon_state = tostring( math.random(1,24) )
	end,
	name = "space",
	desc = "This is a space. Looks strangely sparkly.",
	icon = "icons/turf/space.dmi",
	icon_state = "1"
}
M.space = T{
	new = function(self)
		self.icon_state = tostring( math.random(1,24) )
	end,
	name = "space",
	desc = "This is a space. Looks strangely sparkly.",
	icon = "icons/turf/space.dmi",
	icon_state = "1"
}
M.unsimulated.floor = T{
	name = "floor",
	icon = "icons/turf/floors.dmi",
	icon_state = "floor",
	dense = false,
	opaque = false,
	damaged = T{
		icon_state = "damaged1",
		new = function(self)
			self.icon_state = "damaged" .. math.random(1,5)
		end
	},
	plating = T{
		icon_state = "plating",
		damaged = T{
			new = function(self)
				self.icon_state = "platingdmg" .. math.random(1,3)
			end
		}
	},
	fullred = T{
		icon_state = "fullred"
	},
	red = T{
		icon_state = "red"
	},
	white = T{
		icon_state = "white",
		bot = T{
			icon_state = "bot_white"
		}
	},
	caution = T{
		icon_state = "caution",
		corner = T{
			icon_state = "cautioncorner"
		}
	},
	bot = T{
		icon_state = "bot"
	}
	
}
M.unsimulated.wall = T{
	icon = "icons/turf/walls.dmi",
	icon_state = "",
	dense = true,
	opaque = true,
	name = "wall",
	ancient = T{
		name = "ancient wall",
		icon_state = "ancient"
	}
}
M.unsimulated.void = T{
	icon = "icons/turf/floors.dmi",
	icon_state = "void",
	dense = false,
	name = "void"
}
M.unsimulated.darkvoid = T{
	icon = "icons/turf/floors.dmi",
	icon_state = "darkvoid",
	dense = true,
	opaque = true,
	name = "darkvoid"
}

--[=[TG
M.space.transit = T{
	icon_state = "black",
	dir = 's'
}
M.space.transit.horizontal = T{
	dir = 'w'
}

M.unsimulated.floor = T{
	name = "floor",
	icon = "icons/turf/floors.dmi",
	icon_state = "floor"
}

M.unsimulated.floor.plating = T{
	icon = "icons/turf/floors.dmi",
	name = "plating",
	icon_state = "plating"
}

M.unsimulated.floor.bluegrid = T{
	icon_state = "bcircuit"
}
M.unsimulated.floor.grass = T{
	icon_state = "grass",
	name = "Grass"
}

M.unsimulated.floor.engine = T{
	icon_state = "engine"
}
M.unsimulated.floor.abductor = T{
	name = "alien floor",
	icon_state = "alien1"
}
M.unsimulated.wall = T{
	name = "unsimulated wall",
	icon = "icons/turf/walls.dmi",
	icon_state = "riveted"
}
M.unsimulated.wall.abductor = T{
	name = "alien floor",
	icon_state = "alienpod1"
}
M.unsimulated.wall.normal = T{
	icon_state = "wall"
}
M.unsimulated.wall.fakeglass = T{
	name = "window",
	icon_state = "fakewindows"
}
--[[M.unsimulated.wall.fakedoor = T{
	name = "Centcom Access",
	icon = "icons/obj/doors/Doorele.dmi",
	icon_state = "door_closed"
}]]
M.unsimulated.wall.splashscreen = T{
	name = "Space Station 13",
	icon_state = "title",
	icon = "icons/misc/fullscreen.dmi"
}
M.unsimulated.wall.other = T{
	name = "reinforced wall",
	icon_state = "r_wall"
}
M.unsimulated.wall.vault = T{
	icon_state = "rockvault"
}
M.unsimulated.shuttle = T{
	name = "shuttle",
	icon_state = "wall",
	icon = "icons/turf/shuttle.dmi"
}
M.unsimulated.shuttle.wall = T{
	name = "wall",
	icon_state = "wall1"
}
M.unsimulated.shuttle.floor = T{
	name = "floor",
	icon_state = "floor"
}





M.simulated = T{floor = T{icon = "icons/turf/floors.dmi",icon_state="floor"}, wall = T{name = "wall", desc = "A huge chunk of metal used to separate rooms.", icon = "icons/turf/walls/wall.dmi", icon_state = "wall"}}
M.simulated.floor.wood = T{
	icon_state = "wood"
}
M.simulated.floor.engine = T{
	icon_state = "engine",
	vacuum = T{
		name = "vacuum floor",
	},
	n20=T{}
}
M.simulated.floor.fancy = T{
	icon_state = "fancy floor",
	name = "fancy floor"
}
M.simulated.floor.holofloor = T{
	icon_state = "floor",
	name = "holo floor"
}
M.simulated.floor.grass = T{
	name = "Grass patch",
	icon_state = "grass"
}
M.simulated.floor.grass = T{
	name = "Grass patch",
	icon_state = "grass"
}
M.indestructible = T{
	name = "wall",
	icon = "icons/turf/walls.dmi"
}
M.simulated.floor.carpet = T{
	name = "Carpet",
	icon = 'icons/turf/floors/carpet.dmi',
	icon_state = "carpet"
}

M.simulated.floor.plating = T{
	icon_state = "plating",
	airless = T{}
}
M.simulated.floor.plating.ironsand = T{
	name = "Iron Sand",
	icon_state = "ironsand1",
	new = function(self)
		self.icon_state = "ironsand" .. math.random(1,15)
	end
}
M.simulated.floor.plating.snow = T{
	icon_state = "snow",
	icon = "icons/turf/snow.dmi",
	name = "snow"
}
M.simulated.floor.noslip = T{
	name = "high-traction floor",
	icon_state = "noslip"
}



M.simulated.floor.light = T{
	name = "Light floor",
	icon_state = "light_on"
}

M.simulated.floor.mineral = T{
	name = "mineral floor",
	icon_state = ""
}

M.simulated.floor.mineral.plasma = T{
	name = "plasma floor",
	icon_state = "plasma"
}
M.simulated.floor.mineral.gold = T{
	name = "gold floor",
	icon_state = "gold"
}
M.simulated.floor.mineral.silver = T{
	name = "silver floor",
	icon_state = "silver"
}
M.simulated.floor.mineral.bananium = T{
	name = "bananium floor",
	icon_state = "bananium"
}
M.simulated.floor.mineral.bananium.airless = T{

}
M.simulated.mineral = T{
	name = "mineral",
	icon = "icons/turf/walls.dmi",
	icon_state = "",
	random = T{
		name = "rng mineral",
		high_chance = T{},
		low_chance = T{}
	}
}
M.simulated.floor.mineral.diamond = T{
	name = "diamond floor",
	icon_state = "diamond"
}
M.simulated.floor.mineral.uranium = T{
	name = "uranium floor",
	icon_state = "uranium"
}
M.simulated.floor.plasteel = T{
	name = "plasteel floor",
	icon_state = "floor",
}
M.simulated.floor.mech_bay_recharge_floor = T{
	name = "mechbay recharge station",
	icon_state = "recharge_floor"
}
--M.simulated.floor.plasteel.airless = T{name = "airless plasteel floor"}
M.simulated.floor.goonplaque = T{
	name = "Commemorative Plaque",
	icon_state = "plaque"
}
M.simulated.floor.vault = T{
	icon_state = "vault"
}
M.simulated.floor.bluegrid = T{
	icon_state = "bcircuit"
}
M.simulated.floor.greengrid = T{
	icon_state = "gcircuit"
}
--[[M.simulated.shuttle = T{
	name = "shuttle",
	icon = "icons/turf/shuttle.dmi",
	icon_state = "floor"
}]]

M.simulated.wall.shuttle = T{
	name = "wall",
	icon = "icons/turf/shuttle.dmi",
	icon_state = "wall1"
}
M.simulated.floor.shuttle  = T{
	name = "floor",
	icon = "icons/turf/shuttle.dmi",
	icon_state = "floor"
}



--[[
M.simulated.shuttle.floor4 = T{
	name = "Brig floor",
	icon_state = "floor4"
}]]

M.simulated.floor.beach = T{
	name = "Beach",
	icon_state = "sand",
	icon = "icons/misc/beach.dmi"
}
M.simulated.floor.beach.sand = T{
	name = "Sand",
	icon_state = "sand",
}
M.simulated.floor.beach.coastline = T{
	name = "Coastline",
	icon_state = "sandwater",
	icon = "icons/misc/beach2.dmi",
}
M.simulated.floor.beach.water = T{
	name = "Water",
	icon_state = "water",
}

M.unsimulated.beach = T{
	name = "Beach",
	icon_state = "sand",
	icon = "icons/misc/beach.dmi"
}
M.unsimulated.beach.sand = T{
	name = "Sand",
	icon_state = "sand",
}
M.unsimulated.beach.coastline = T{
	name = "Coastline",
	icon_state = "sandwater",
	icon = "icons/misc/beach2.dmi",
}
M.unsimulated.beach.water = T{
	name = "Water",
	icon_state = "water",
}

M.simulated.floor.plasteel = T{
	name = "plasteel floor",
	icon_state = "floor"
}
M.simulated.floor.plasteel.shuttle = T{
	icon_state = "shuttlefloor",
}

M.simulated.wall.cult = T{
	name = "cult wall",
	icon_state = "cult"
}
M.simulated.wall.vault = T{
	icon_state = "rockvault"
}
M.simulated.wall.rust = T{
	name = "rusted wall",
	icon_state = "arust"
}

M.simulated.wall.r_wall = T{
	name = "reinforced wall",
	icon = "icons/turf/walls/reinforced_wall.dmi",
	desc = "A huge chunk of reinforced metal used to separate rooms.",
	icon_state = "r_wall"
}
M.simulated.wall.r_wall.rust = T{
	icon_state = "rrust",
	name = "rusted reinforced wall"
}
M.simulated.wall.mineral = T{
	name = "mineral wall"
}
M.simulated.wall.mineral.gold = T{
	name = "gold wall",
	icon_state = "gold0"
}
M.simulated.wall.mineral.silver = T{
	name = "silver wall",
	icon_state = "silver0"
}
M.simulated.wall.mineral.clown = T{
	name = "bananium wall",
	icon_state = "bananium0"
}
M.simulated.wall.mineral.diamond = T{
	name = "diamond wall",
	icon_state = "diamond0"
}
M.simulated.wall.mineral.sandstone = T{
	name = "sandstone wall",
	icon_state = "sandstone0"
}
M.simulated.wall.mineral.uranium = T{
	name = "uranium wall",
	icon_state = "uranium0"
}
M.simulated.wall.mineral.plasma = T{
	name = "plasma wall",
	icon_state = "plasma0"
}
M.simulated.wall.mineral.wood = T{
	name = "wooden wall",
	icon_state = "wood0"
}]=]

--[[
turf.unsimulated.__index = turf
turf.unsimulated.floor.__index = turf.unsimulated
turf.unsimulated.floor.bluegrid.__index = turf.unsimulated.floor
----------------------------------------------------------------
turf.unsimulated.floor.bluegrid.hello		  |
turf.unsimulated.floor.bluegrid['hello']? NO? V
turf.unsimulated.floor['hello']? NO? |
turf.unsimulated['hello']? NO? |    <-
turf[ 'hello' ]? NO? OH WELL.
]]
local ID = 0

local M2 = {}
local easypath = {}
local rawashell = function(t,k) return rawget( t.__index, k ) or t.parent[ k ]end
local function metaify( t, iters, st, path, parent )
	iters = iters or 0
	for k, v in pairs( t ) do
		local path = path
		if( type( v ) == 'table' and v.TYPE == 'turf' ) then
			path = path .. "/" .. k
			v.path = path
			if v.icon then
				v.icon = icons(v.icon,v.log)
				if not v.icon then error("No icon.") end
			end
			v.typeid = ID
			
			setmetatable( v, {__index = t} )

			--[[local st = setmetatable( {__hack=v}, {__index=rawashell} )
			metaify( v, iters + 1, subtable2 )
			subtable[ k ] = st]]
			
			io.write( ("| "):rep(iters) .. k .. "[" .. (v.icon and 'iconned' or 'uniconned') .. "]: " .. path .. "( id: " .. v.typeid .. " )\n" )
			local t = {__index = v, typeid = ID}
			subtable = {__TURF = t}
			
			st[ k ] = subtable
			easypath[path]=subtable
			ID = ID + 1
			metaify( v, iters + 1, subtable, path, t )
		end
	end

end
metaify( M, 0, M2, "/turf" )

function easypath.getByID( id )
	for k, v in pairs( easypath ) do
		if( v ~= easypath.getByID and v.typeid == id ) then
			return v
		end
	end
end

--assert(setmetatable({},M2.unsimulated.beach.sand.__TURF).icon)
--print(M['unsimulated.floor.bluegrid'])
return {M2,easypath}
