local panel = class( 'gui.Dragger', 'gui.Button' )
panel.minW = 16
panel.minH = 16
panel.pressable = false
function panel:init( tgt )
	self.target = tgt or (self.parent and self.parent.parent and self.parent) or self
	self.mode   = 'position'
	self:setCursor( 'hand' )
	--self:setPressable( false )
end
function panel:setMode( mode )
	self.mode = mode or 'position'
	if mode == 'sizese' then
		self:setDrawBackground( false )
		self:setCursor( 'sizenwse' )
	else
		self:setCursor( 'sizeall' )
	end
end
function panel:setTarget( tgt )
	self.target = tgt or self
end
function panel:onmousemove( x, y, rx, ry )
	if self.depressed then
		if self.mode == 'position' then
			self.target:setPos( self.target.x + rx, self.target.y + ry )
		elseif self.mode == 'sizese' then
			self.totalW = self.totalW + rx
			self.totalH = self.totalH + ry
			self.target:setSize( self.totalW, self.totalH )
		end
	end
end
function panel:onmousedown( btn, x, y )
	if self.depressed then
		self.totalW = self.target:getWidth()
		self.totalH = self.target:getHeight()
		if self.mode == 'position' then
			self:setCursor( 'sizeall' )
			gui.setCursor('sizeall')
		end
	end
end
function panel:onmouseup(btn)
	if btn == MOUSE_LEFT and self.mode == 'position' then
		self:setCursor( 'hand' )
		gui.setCursor('hand')
	end
end
local scheme = require( 'gui.scheme' )
function panel:draw()
	if self.mode == 'sizese' then
		gui.drawIcon( 'sizese', 0, 0, scheme.dragger.sizerColor )
	else
		panel.baseclass.draw( self )
	end
end

return panel
