--[[
	welcome to byand the realities of life
]]
local sock = require'socket'.tcp()
sock:connect( '127.0.0.1', 7777 )
local m = require'client.packetengine'
m.socket = sock
m.hello( 506, 276, 1, 1 )
m.encryption = 1
m.sequence = 1