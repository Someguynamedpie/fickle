--[[
main Fickle game logic
]]

game = {}



local activeState, activeMenu
function game.setState( newstate )
	if activeState then
		--activeState:leave( newstate )
	end
	activeState = newstate
	--newstate:enter()
end
function game.setMenu( newmenu )
	--gui.clear
	if activeMenu then
		activeMenu:close()
	end
	activeMenu = newmenu
	if activeMenu then
		newmenu:open()
	end
end
if not DEDICATED then
	function game.connect( ip, port )
		if net.isConnected() or net.isHosting() then net.disconnect() end
		game.setState( STATE_CONNECTING )
		net.connect( ip, port )
	end

end

function game.handleChat(ply, msg, team)
	
end
