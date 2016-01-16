local panel = class( "gui.DropDown", "gui.Button" )
panel.rOffY = 3--todo align better
function panel:init()
	self.entries = {}
	self.menu = gui.new( 'menu' )
	self.menu:setDeleteOnClose( false )
	self.menu:setVisible( false )
	--self:setTogglable( true )
	
	function self.menu.onhide(_, pushed)
		
		if self.wait == nil then
			--self.wait = not pushed
			--print('set wait to ' .. tostring(self.wait))
		end
		self.toggled = false	
		
		
	end
	self:setText( "Select..." )
end
function panel:ondown( )
	--if self.wait then self.wait = false print'wait' return end
	
	--self.wait = nil
	if self.toggled then
		self.menu:setVisible( false )
		self.toggled = false
		return
	end
	self.toggled = true
	self.menu:show()
	self.menu:setPos( self:localToWorld( 0, self:getHeight() ) )
end

function panel:onselect(data)
	
end

function panel:addItem( label, data )
	self.menu:addItem( label, function() self:onselect( data or label ) self:setText( label ) end )
	table.insert( self.entries, {label = label, data = data} )
end
function panel:draw()
	self.baseclass.draw( self )
	gui.drawIcon( 'down', self.w - 32, self.h / 2 - 8 )
end
return panel