local M = {}
local game = require'game'
local map = require'sandgoon.level'

function M.update()
end

function M.isHoster()
	return net.isHosting()
end

function M.changeMap( newmap )-- TODO: Verification
	if( game.getLevel() ) then
		local newMap = map.load( newmap )
		net.broadcast( S2C_MapSetup, { width = newmap.width, height = newmap.height, depth = newmap.depth } )
		game.setLevel( newMap )
	else
		game.setLevel( map.load( newmap ) )
	end
end