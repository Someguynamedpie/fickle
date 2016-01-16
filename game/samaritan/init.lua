--[[
Welcome to SAMARITAN, a self-learning data retrieval AI.
]]
local viewport = gui.new('panel')
viewport:setMargins( 0, 0, 0, 0 )
viewport:dock(DOCK_FILL)
function viewport.paint() end
local icons = Texture("samaritan/cities.png")
local line = Texture("samaritan/cityline.png")

local bigfont = require('video.freetype').loadFont( "magdacleanmono-regular.otf" , {size=32} )

local groups = {}
math.randomseed(os.time())
local function newGroup(rand)
	local group = {cities = {}, dir = math.random()>=.5, y = rand and rand or 0}
	for i = 1, math.random( 1, 4 ) do
		table.insert(group.cities, {x = math.random( 0, 1 ) * 64, y = math.random(0,3) * 32})
	end
	table.insert(groups, group)
end
local system = require'system'
function viewport:draw()
	if(#groups < 5 and math.random()<=.05) then newGroup() end
	local w, h = self.w, self.h
	local n = math.random(230,240)
	surface.setDrawColor( n, n, n )
	surface.fillRect( 0, 0, w, h )
	
	for i = 1, 5 do
		surface.setDrawColor(60, 60, 60)
		surface.fillRect( math.sin(system.getTime() * i) * viewport.w, 0, 2, viewport.h)
	end
	
	--surface.setTexture(icons)
	surface.setTextureColor(255,255,255)
	for k, v in pairs( groups ) do
		if(v.y > viewport.h) then
			table.remove(groups,k)
			newGroup()
		end
	end
	for k, v in pairs( groups ) do
		v.y = v.y + 15
		local dir = v.dir
		--function M.drawTexturedSubrect( x, y, w, h, ix, iy, iw, ih, ang, flip, originX, originY )
		surface.setDrawColor( 128, 128, 128)
		surface.fillRect( dir and 0 or (viewport.w - 2), v.y - 1, 2, (40*(#v.cities-1) + 1))
		for i = 1, #v.cities do
			local city = v.cities[i]
			surface.setTexture(line)
			surface.drawTexturedSubrect(dir and 0 or (viewport.w - 32), v.y + (i-1)*40, 32, 32, 0, 0, 32, 32, 0, dir and 0 or FLIP_X)
			surface.setTexture(icons)
			
			surface.setTextureColor(255,255,255, 128)
			surface.drawTexturedSubrect(dir and 32 or (viewport.w - 64 - 32), v.y + (i-1) * 40, 64, 32, city.x, city.y, 64, 32)
		end
	end
	surface.setFont(bigfont)
	surface.setTextColor(0,0,0,64 + math.random(10,40))
	surface.drawText("SAMARITAN", 0, 0)
	surface.setFont()
	self:paint(w,h)
end


loadfile("game/samaritan/splash.lua")(viewport)