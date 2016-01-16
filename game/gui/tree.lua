local panel = class( 'gui.Tree', 'gui.Panel' )
function panel:init()
	self.root = gui.new( 'treenode', self )
	self.root:setRoot( true )
	self.root:dock( FILL )
end