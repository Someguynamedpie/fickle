local gui = ...
local panel = class( 'gui.Menu', 'gui.Panel' )
panel.ISMENU = true
panel.deleteonclose = true

local removables = {}
function panel:init()
	table.insert( removables, self )
	self.totalY = 0
end
function panel:show()
	self:setVisible( true )
	self:bringToFront()
	self:makePopup()
end

function panel:onremove()
	for i, v in ipairs( removables ) do
		if( v == self ) then
			table.remove( removables, self )
		end
	end
end
function panel:hide(pushed)
	if self:isVisible() then
		self:setVisible(false)
		self:onhide(pushed)
	end
end
function gui.onnonmenuclick( f )
	for i, v in ipairs( removables ) do
		if( v ~= f ) then
			if( v == self and v.deleteonclose ) then
				v:remove()
			elseif not v.deleteonclose then
				v:hide()
				
			end
		end
		
	end
	
	
end

function panel:onhide( ) end

function panel:setDeleteOnClose( bool )
	self.deleteonclose = bool
end

function panel:addPanel( pan )
	pan:dock( DOCK_TOP )
	pan:setMargins( -3, -3, -3, 4 )
	self.totalY = self.totalY + pan:getHeight() + 2
	self:setHeight( self.totalY )
	self:setWidth( math.max( self:getWidth(), pan:getWidth() ) )
end

function panel:addItem( label, cb )
	local opt = gui.new( 'button', self )
	opt:setText( label )
	opt.onclick = function() self:hide(true) if cb then cb() end end
	opt:setWidth( surface.getTextSize( label ) + 8 )
	opt:setHeight( 16 )
	self:addPanel( opt )
end

return panel