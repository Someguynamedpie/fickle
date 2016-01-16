local panel = class( 'gui.Image', 'gui.Panel' )
function panel:setImage( path )
	self.texture = Texture( path )
end
function panel:draw()
	surface.setTexture( self.texture )
	surface.drawTexturedRect( 0, 0, self.w, self.h )
end

print(panel.setParent)
return panel