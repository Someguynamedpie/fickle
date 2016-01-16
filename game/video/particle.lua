local M = {}M.__index=M
local system = require'system'


function M:draw(x,y)
	local i = 1
	surface.setTexture(self.texture)
	
	
	
	while i <= #self.particles do
		local part = self.particles[i]
		if part then
			if part.dieAt <= system.getTime() then
				table.remove(self.particles, i)
				i = i - 1
			else
				local perc = (part.dieAt - system.getTime())
				
				
				surface.setTextureColor(part.dieCol:fadeTo(part.col, perc))
				
				surface.drawTexturedRect(x + part.x, y + part.y, self.texture.width, self.texture.height)
				part.x = part.x + part.vx
				part.y = part.y + part.vy
			end
		else break end
		i = i + 1
	end
end
function M:addParticle( x, y )
	local part = setmetatable({x = x, y = y, col = color_white, dieCol = color_black, dieAt = system.getTime() + 1, dieAlpha = 0},M)
	
	table.insert(self.particles, part)
	return part
end
function M:new(tex)
	return setmetatable({particles = {}, texture = tex}, M)
end
return M