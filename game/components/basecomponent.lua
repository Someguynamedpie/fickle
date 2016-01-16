local bc = class( "BaseComponent" )
BaseComponent = bc
bc.networked = false--whether or not this component is networked. automatically set if you add a datatable entry

--Call this during the entity definition.
function bc:DTAdd( key, type, default )
	self.dtvars = self.dtvars or {}
	table.insert( self.dtvars, {key = key, type = type, default = default} )
	self.networked = true
end

function bc:dtSetup( data )
	for i = 1, self.dtvars do
		self.dt[ self.dtvars[ i ].key ] = data:readType( self.dtvars[ i ].type )
	end
end

function bc:dtGet( key )
	return self.dt[ key ]
end