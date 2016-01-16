local panel = class( 'gui.Frame', 'gui.Panel' )
panel.minW = 64
panel.minH = 32
function panel:init( tgt )
	self.title = gui.new( 'dragger', self, self )
	self.title:setText( "Frame" )
	self.title:setHeight( 22 )
	self.title:setMargins( -3, -3, -3, 4 )
	self.title:setPadding( 0, 0, 0, 0 )
	self.title:dock( DOCK_TOP )
	self.title:align(ALIGN_CENTER)
	self.title:makePopup()

	self.handle = gui.new( 'dragger', self, self )
	self.handle:setMode( 'sizese', 'se' )
	self.handle:setSize( 8, 10 )

	self.xbutton = gui.new( 'button', self.title )
	self.xbutton:dock(DOCK_RIGHT)
	self.xbutton:setMargins( 0, 0, 0, 0 )
	self.xbutton:setIcon('close')
	function self.xbutton.onclick() self:remove() end
	self:setSize( 200, 200 )
	self.handle:makePopup()
	
end
function panel:onlayout()
	self.handle:setPos( self:getWidth() - 8, self:getHeight() - 10 )
end
function panel:setTitle( title )
	self.title:setText( title )
end
return panel
