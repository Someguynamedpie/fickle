local class = require'middleclass'
ComponentSystem = class( "ComponentSystem" )

local componentMap = {}
function ComponentSystem:addComponent( name )
	self.components = self.components or {}
	local comp = componentMap[ name ]:new( self )
	self.components[ name ] = comp
	return comp
end

function ComponentSystem:getComponent( name )
	return self.components and self.components[ name ]
end

function game.newComponent( name )
	return class( name .. "Component", "BaseComponent" )
end

reqiore( "components.basecomponent" )