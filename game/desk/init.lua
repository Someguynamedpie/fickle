--[[
Welcome to DESK, the computing envionment without words to go with its acronym
]]

local viewport = gui.new('panel')
viewport:setMargins( 0, 0, 0, 0 )
viewport:dock(DOCK_FILL)

function viewport:paint()
	surface.setDrawColor( 255, 255, 255 )
	surface.fillRect( ScrW / 2, ScrH / 2, 8, 8 )
end