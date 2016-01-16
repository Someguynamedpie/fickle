local M = {}
M.__index = M

function M:draw( x, y, w, h )
	
	surface.setTexture(self.tex)
	--draw corners
	--TL
	surface.drawTexturedSubrect( x, y, self.corner, self.corner, self.x, self.y, self.corner, self.corner )
	--TR
	surface.drawTexturedSubrect( x + w - self.corner, y, self.corner, self.corner, self.x + self.w - self.corner, self.y, self.corner, self.corner )
	--BL
	surface.drawTexturedSubrect( x, y + h - self.corner, self.corner, self.corner, self.x, self.y + self.h - self.corner, self.corner, self.corner )
	--BR
	surface.drawTexturedSubrect( x + w - self.corner, y + h - self.corner, self.corner, self.corner, self.x + self.w - self.corner, self.y + self.h - self.corner, self.corner, self.corner )
	
	--TOP
	surface.drawTexturedSubrect( x + self.corner, y, w - self.corner*2, self.corner, self.x + self.corner, self.y, self.x + self.corner, self.corner )
	--LEFT
	surface.drawTexturedSubrect( x, y + self.corner, self.corner, h - self.corner*2, self.x, self.y + self.corner, self.corner, self.h - self.corner*2 )
	--BOTTOM
	surface.drawTexturedSubrect( x + self.corner, h - self.corner, w - self.corner * 2, self.corner, self.x + self.corner, self.h - self.corner, self.w - self.corner*2, self.corner )
	--RIGHT
	surface.drawTexturedSubrect( x + w - self.corner, y + self.corner, self.corner, h - self.corner * 2, self.x + self.w - self.corner, self.y + self.corner, self.corner, self.h - self.corner*2)
	
	--CENTER
	surface.drawTexturedSubrect( x + self.corner, y + self.corner, w - self.corner * 2, h - self.corner * 2, self.x + self.corner, self.y + self.corner, self.w - self.corner * 2, self.h - self.corner * 2)
end

function M.new( texture, x, y, w, h, corner )
	return setmetatable( {tex = texture, x = x, y = y, w = w, h = h, corner = corner}, M )
end
return M
