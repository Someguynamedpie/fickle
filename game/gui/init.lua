local M = {}

local rootPanel
local registered = {}
function M.new( type, parent, ... )
	local ret = registered[ type ]:new( ... )
	if parent then ret:setParent(parent) end
	return ret
end

function M.update()
	rootPanel:render()
end
function M.setFocus( f, nav )
	
	if f then
		if not f.ISMENU and (not f.parent or not f.parent.ISMENU) then gui.onnonmenuclick() end
		local exFocus = M.focus
		M.focus = f
		if exFocus ~= M.focus then
			if exFocus then exFocus:onfocus( false ) exFocus.focussed = false end
			M.focus:onfocus( true, nav )
			M.focus.focussed = true
			if not M.focus.parent or not M.focus.parent.parent then M.focus:bringToFront() end
		end
	elseif M.focus then M.focus:onfocus( false, nav ) M.focus.focussed = false end
end
--returns true to suppress bubbling
function M.pushEvent( evt, data )
	if evt == 'mousepress' then
		if M.focus then M.focus.depressed = false end
		if( data.button == MOUSE_LEFT or data.button == MOUSE_RIGHT ) then
			M.setFocus( rootPanel:getPanelOverPoint( data.x, data.y, true ) )
			if M.focus then M.focus.depressed = true end
		end
		if M.focus then
			data.x, data.y = M.focus:worldToLocal( data.x, data.y )
			M.focus:onmousedown( data.button, data.x, data.y, data.clicks )
			 M.focus:bringToFront()
		end
	elseif evt == 'mouserelease' then
		if M.focus then
			local f = M.focus
			if not f.ISMENU and (not f.parent or ( not f.parent.ISMENU ) ) then gui.onnonmenuclick( f.menu ) end
			data.x, data.y = M.focus:worldToLocal( data.x, data.y )
			
			M.focus:onmouseup( data.button, data.x, data.y, data.clicks )
			if data.button == MOUSE_LEFT or data.button == MOUSE_RIGHT then M.focus.depressed = false end
		end
	elseif evt == 'mousemove' then
		local hover = rootPanel:getPanelOverPoint( data.x, data.y, true )
		if hover ~= M.hover then
			if M.hover then M.hover.hover = false end
			if hover then hover.hover = true
			end

			M.hover = hover

		end
		if hover then
			local rx, ry = hover:worldToLocal( data.x, data.y )
			hover:onmousemove( rx, ry, data.rx, data.ry )
			if (M.focus and not M.focus.depressed) or not M.focus then gui.setCursor( hover.cursor ) end
		end
		if hover ~= M.focus and M.focus and M.focus.depressed then
			local rx, ry = M.focus:worldToLocal( data.x, data.y )
			M.focus:onmousemove( rx, ry, data.rx, data.ry )
			if (M.focus and not M.focus.depressed) or not M.focus then gui.setCursor( M.focus.cursor ) end
		end
	elseif evt == 'textinput' and M.focus then if M.suppress then M.suppress = false return end
		M.focus:ontextinput( data.text )
	elseif evt == 'textime' and M.focus then if M.suppress then return end
		M.focus:onime( data.text, data.start, data.length )
	elseif evt == 'keydown' and M.focus then
		if data.key == sdl.KEY_BACKQUOTE then M.suppress = true return end
		if( data.key == sdl.KEY_TAB ) then
			if input.hasModifier( data.modifiers, MOD_SHIFT ) then
				M.focus:navigate( NAV_UP )
			else
				M.focus:navigate( NAV_DOWN )
				
			end
		else
			M.focus:onkeypress( data.key, data.modifiers, data.rep )
		end
	elseif evt == 'keyup' and M.focus then
		if data.key == sdl.KEY_BACKQUOTE then
			require'console'.toggle()
		else
			M.focus:onkeyrelease( data.key, data.modifiers, data.rep )
		end
	elseif evt == 'scroll' and M.hover then
		M.hover:onscroll( data.x, data.y )
	end
	if evt == 'resize' then
		rootPanel:setSize(data.w, data.h)
	end

	return M.focus and true or false
end

function M.clear() print'clearing'
	rootPanel:clear()
end
gui = M
registered['panel'] = loadfile( 'game/gui/panel.lua' )( M )--require( "gui.panel", M )
registered['image'] = require( "gui.image" )
registered['label'] = require( "gui.label" )
registered['button'] = require( "gui.button" )
registered['textbox'] = require( "gui.textbox" )
registered['dragger'] = require( "gui.dragger" )
registered['frame'] = require( "gui.frame" )
registered['checkbox'] = require( "gui.checkbox" )
registered['richtext'] = require( "gui.richtext" )
registered['menubar'] = require( "gui.menubar" )
registered['menu'] = loadfile( 'game/gui/menu.lua' )( M )--require( "gui.panel", M )
registered['menuitem'] = require( "gui.menuitem" )
require'gui.keyboard'
registered['osk'] = loadfile( 'game/gui/keyboard.lua' )( M )--require( "gui.panel", M )
registered['dropdown'] = require( 'gui.dropdown' )

rootPanel = M.new( 'panel' )
rootPanel:setSize( video.getSize() )

gui = nil
M.root = rootPanel

M.iconTex = Texture( "gui/icons.png" )
local icons = {
	["sizese"] =
		{8, 4, 8, 10},
	["checkmark"] =
		{32, 32, 16, 16},
	["cross"] =
		{16, 32, 16, 16},
	["box"] =
		{0, 32, 16, 16},
	["close"] =
		{48, 0, 16, 16},
	["down"] =
		{48, 48, 16, 16}

}
function M.drawIcon( icon, x, y, color, w, h )
	color = color or color_white
	icon = icons[ icon ]

	if icon then
		surface.setTexture( M.iconTex )

		surface.setTextureColor( color )
		surface.drawTexturedSubrect( x, y, w or icon[3], h or icon[4], icon[1], icon[2], icon[3], icon[4] )
	end
end

local cursors = {
	['arrow'    ] = sdl.CreateSystemCursor( sdl.SYSTEM_CURSOR_ARROW ),
	['ibeam'    ] = sdl.CreateSystemCursor( sdl.SYSTEM_CURSOR_IBEAM ),
	['wait'     ] = sdl.CreateSystemCursor( sdl.SYSTEM_CURSOR_WAIT ),
	['crosshair'] = sdl.CreateSystemCursor( sdl.SYSTEM_CURSOR_CROSSHAIR ),
	['waitarrow'] = sdl.CreateSystemCursor( sdl.SYSTEM_CURSOR_WAITARROW ),
	['sizenwse' ] = sdl.CreateSystemCursor( sdl.SYSTEM_CURSOR_SIZENWSE ),
	['sizenesw' ] = sdl.CreateSystemCursor( sdl.SYSTEM_CURSOR_SIZENESW ),
	['sizewe'   ] = sdl.CreateSystemCursor( sdl.SYSTEM_CURSOR_SIZEWE ),
	['sizens'   ] = sdl.CreateSystemCursor( sdl.SYSTEM_CURSOR_SIZENS ),
	['sizeall'  ] = sdl.CreateSystemCursor( sdl.SYSTEM_CURSOR_SIZEALL ),
	['no'       ] = sdl.CreateSystemCursor( sdl.SYSTEM_CURSOR_NO ),
	['hand'     ] = sdl.CreateSystemCursor( sdl.SYSTEM_CURSOR_HAND )
}
function M.setCursor( name )
	cursor = cursors[ name ] or cursors.arrow
	sdl.SetCursor( cursor )
end
--]]

return M
