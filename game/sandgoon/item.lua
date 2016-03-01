local icons = require'sandgoon.icons'.loadDMI
local function I(i) i.color = i.color or color_white i.TYPE = 'item' return t end
local M = I{
	name = "unnamed",
	icon = "",
	maxstack = 1,
	container = 0,
	stats = {}
}

SLOT_HANDS = 1
SLOT_JUMPSUIT = 2
SLOT_BELT = 3
SLOT_ID = 4
SLOT_FEET = 5
SLOT_CHEST = 6

M.equippable = I{
	slot = 0--not actually equipable
	durability_max = 0, -- durability cap
	durability = 0,--current durability, if it reaches 0 the equipment is shattered.
	icon_world = "",--world icon
	state_world = "",--world iconstate
}
M.equippable.hands = I{
	slot = SLOT_HANDS
}
M.equippable.hands.gloves = I{
	name = "Gloves",
	icon = 'icons/obj/clothing/item_gloves.dmi'
}

M.equippable.hands.gloves.electrical = I{
	name = "Electrical Gloves",
	icon_state = "yellow"
	stats = {
		{type = STAT_RESIST, subtype = DMG_ELECTRICAL, power = 1, direct = true}--100% protection from electrical damage dealt to hands
	},
}

local ID = 0

local M2 = {}
local easypath = {}
local rawashell = function(t,k) return rawget( t.__index, k ) or t.parent[ k ]end
local function metaify( t, iters, st, path, parent )
	iters = iters or 0
	for k, v in pairs( t ) do
		local path = path
		if( type( v ) == 'table' and v.TYPE == 'item' ) then
			path = path .. "/" .. k
			v.path = path
			if v.icon then
				v.icon = icons(v.icon,v.log)
				if not v.icon then error("No icon.") end
			end
			v.typeid = ID
			
			setmetatable( v, {__index = t} )
			
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
metaify( M, 0, M2, "/item" )

function easypath.getByID( id )
	for k, v in pairs( easypath ) do
		if( v ~= easypath.getByID and v.typeid == id ) then
			return v
		end
	end
end