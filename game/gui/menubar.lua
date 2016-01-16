local panel = class( 'gui.MenuBar', 'gui.Panel' )

function panel:init()
	self:dock( DOCK_TOP )
	self:setHeight( 32 )
end

function panel:addMenu( label )
	local menubtn = gui.new( 'button', self )
	menubtn:dock( DOCK_LEFT )
	menubtn:setWidth( surface.getTextSize( label ) + 32 )
	menubtn:align( ALIGN_CENTER )
	menubtn:setText( label )
	
	local menu = gui.new( 'menu' )
	menu:setDeleteOnClose( false )
	menu:setVisible( false )
	menu:setWidth( menubtn:getWidth() )
	menubtn.menu = menu
	
	function menubtn:ondown( )
		if self.toggled then
			menu:setVisible( false )
			return
		end
		self.toggled = true
		menu:show()
		menu:setPos( self:localToWorld( 0, self:getHeight() ) )
	end
	
	function menubtn:onup()
		--menu:hide()
	end
	
	function menu:onhide()
		menubtn.toggled = false
	end
	
	
	return menu, menubtn
end

return panel