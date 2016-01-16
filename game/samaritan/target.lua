local overlay=...
local finder = gui.new("panel", overlay)
finder:setSize( 300, 60 )
finder:center()
finder:fadeIn()
function finder:draw()
	surface.setTextColor( 150, 150, 150 )
	surface.drawText( "ENTER TARGET", 8, 2 )
end
local entry = gui.new("textbox", finder )
entry:dock( DOCK_BOTTOM )
entry:setBackgroundColor( Color( 0, 0, 0 ) )
entry.upper = true
entry:setPattern("[a-zA-Z, ]")