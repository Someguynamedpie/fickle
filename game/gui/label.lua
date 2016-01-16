local panel = class( 'gui.Label', 'gui.Image' )
local tween = require'lib.tween'
panel.text = 'Label'
panel.font = surface.getFont()
panel.rOffX = 0
panel.rOffY = 0


ALIGN_LEFT = function( txt )
	return 0, 0
end
ALIGN_CENTER = function( txt, w, h )
	local W, H = surface.getTextSize(txt)
	return w/2 - W/2, h/2 - H/2
end
panel.alignment = ALIGN_CENTER
function panel:setText( text, animate )
	if animate then
		tween.remove( self.tween )
		self.exText = self.text
		self.exTextAlpha = 1
		self.tween = tween.new( self, {exTextAlpha = 0}, 1, 'outCubic', function() self.exText = nil self.exTextAlpha = nil end )
	end
	self.text = text
end



function panel:align( alignment )
	self.alignment = alignment or ALIGN_CENTER
end
function panel:setFont( font )
	self.font = font
end
function panel:draw()
	surface.setFont( self.font )
	surface.setTextColor( self.color or color_white )
	if self.exText then
		surface.setAlphaMultiplier( self.exTextAlpha )

		local oX, oY = self.alignment( self.exText, self.w, self.h )

		surface.drawText( self.exText, oX + self.rOffX, oY + self.rOffY )
		surface.setAlphaMultiplier( 1 - self.exTextAlpha )
	end
	local oX, oY = (self.alignment or ALIGN_LEFT)( self.text, self.w, self.h )
	if( self.texture ) then
		surface.setTexture( self.texture )
		if( self.alignment == ALIGN_LEFT ) then oX = oX + self.texture.width + 1 end
		surface.drawTexturedRect( 2 + self.rOffX, self.h / 2 - self.texture.height / 2, self.texture.width, self.texture.height )

	end
	surface.drawText( self.text, oX + self.rOffX, oY + self.rOffY )


end
return panel
