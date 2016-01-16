local panel = class( 'gui.Button', 'gui.Label' )
panel.bg = true
panel.pressable = true
local scheme = require( 'gui.scheme' )
function panel:setDrawBackground( bg )
	self.bg = bg
end
function panel:setPressable( pressable )
	self.pressable = pressable
end

function panel:setTogglable( togglable )
	self.togglable = togglable
	if not togglable then self.toggled = false end
end

function panel:ontoggle( toggled ) end

function panel:draw( )
	if self.bg then
		local depressed = ((self.depressed and self.hover) or self.toggled) and self.pressable
		if depressed then
			surface.setDrawColor( scheme.button.backgroundPress )
		elseif self.hover and self.pressable then
			surface.setDrawColor( scheme.button.backgroundHover )
		else
			surface.setDrawColor( scheme.button.background )
		end
		surface.fillRect( 0, 0, self.w, self.h )

		if depressed then
			surface.setDrawColor( scheme.button.border )
		else
			surface.setDrawColor( scheme.button.borderBright )
		end
		surface.drawRect( 0, 0, self.w, self.h )

		if not depressed then
			surface.setDrawColor( scheme.button.border )
		else
			surface.setDrawColor( scheme.button.borderBright )
		end
		surface.drawRect( 0, self.h - 1, self.w, 2 )
		surface.drawRect( self.w - 1, 0, 2, self.h )
	end
	if self.icon then
		gui.drawIcon( self.icon, self.w / 2 - 8, self.h / 2 - 8 )
	else
		panel.baseclass.draw( self )
	end

end

function panel:setIcon(icon)
	self.icon = icon
end

function panel:onmouseup( btn, x, y )
	if btn == MOUSE_LEFT and self.hover then
		--
		self:onup()
		self:onclick( x, y )
		if self.togglable then
			self.toggled = not self.toggled
			self:ontoggle( self.toggled )
		end
		
	end
end
function panel:onmousedown( btn, x, y )
	if btn == MOUSE_LEFT then self:ondown() end
end
function panel:onclick(x,y) end
function panel:onup(x,y) end
function panel:ondown(x,y) end
return panel
