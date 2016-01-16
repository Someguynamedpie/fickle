local Stack = class( 'lib.Stack' )
function Stack:initialize()
	self.stack = {}
end
function Stack:push( evt )
	table.insert( self.stack, evt )
end
function Stack:pop()
	return table.remove( self.stack, 1 )
end
return Stack