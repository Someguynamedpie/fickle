local gui = require'gui'
local M = {}

local function skeletalDialog()
	local window = gui.new('frame')
	window:setSize(300,196)
	window:setTitle("Create Skeleton...")
	local skelName = gui.new('textbox', window)
	skelName:dock(DOCK_TOP)
	skelName:setPlaceholder("Name")
	local texSel = gui.new('textbox', window) skelName:setNavTarget( NAV_DOWN, texSel ) skelName:setNavTarget( NAV_UP, texSel )
	texSel:dock(DOCK_TOP)
	texSel:setPlaceholder("Texture Folder")
	local ok = gui.new('button', window) ok:align(ALIGN_CENTER)
	ok:setText("Start")
	ok:dock(DOCK_TOP)
	local cancel = gui.new('button',window) cancel:align(ALIGN_CENTER)
	cancel:setText("Cancel")
	cancel:dock(DOCK_TOP)
	cancel.onclick = window.xbutton.onclick
end

function M:enter()
	local menubar = gui.new( 'menubar' )
	menubar:setMargins( -3, -3, -3, 0 )
	
	local menu = menubar:addMenu( "New..." )
	menu:addItem( "Skeleton", skeletalDialog )
	
end

function M:leave() end
return M