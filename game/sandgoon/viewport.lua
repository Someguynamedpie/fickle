local panel = class( 'gui.SGViewport', 'gui.Panel' )
local game = require( "sandgoon.game" )

function panel:setEye( ent )
	self.eye = ent
end

function panel:draw()
	surface.setTexture( self.texture )
	surface.drawTexturedRect( 0, 0, self.w, self.h )
end


return panel