--do return require'client' end

IN_FORWARD = 1
IN_BACK    = 2
IN_LEFT    = 4
IN_RIGHT   = 8

local connecting = false
local system = require'system'
require'sandgoon.net'
local map = require'sandgoon.level'
local fov = require'sandgoon.fov'
local dmi = require'video.dmi'
local surface = require'video.surface'

local panel = gui.new'panel'

local bind = require'binds'

panel.parent:setPadding( 0, 0, 0, 0 )
panel:setMargins( 0, 0, 0, 0 )
panel:dock(DOCK_FILL)
local log = gui.new('richtext', panel)
log:dock(DOCK_BOTTOM)
log:setHeight( 300 )
log.passthru = true
log:setBackgroundColor( Color(0,0,0,0))
log.opacity = 0.75
log:setMargins( 0, 0, 0, 16 )
function world(...)
	log:addText( ... )
end
--local floor = Texture'icons/turf/space.dmi'
--dmi.load(floor)
--[[
]]
--[[local level = {}
for z = 1, 6 do
	for x = 1, 300 do
		for y = 1, 300 do
			level[ x ] = level[ x ] or {}
			level[ x ][ y ] = level[ x ][ y ] or {}
			level[ x ][ y ][ z ] = { icon = floor, state = tostring(math.random(1,24)), dir = 's' }
		end
	end
end]]
local turf, pathturf = unpack(require'sandgoon.turf')

local level
require'audio.music'.setQueue{require'audio'.loadSource'sound/ambience/voidambi.ogg'}
--[[for z = 1,	1 do
	for x = 1, 100 do
		for y = 1, 100 do
			level:setTurf( x, y, z, turf.unsimulated.darkvoid, true )
		end
	end
end]]
local floor = math.floor
local mceil = math.ceil
local round = math.round
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local mmax = math.max
local mmin = math.min
local abs=math.abs
local lvl
local audio = require'audio'

local ply

local function say( str )
	if net.isConnected() then
		net.sendToServer( NET_ChatMessage, {id=0, message=str} )
	else
		ply:say( str )
	end
end

local function renderMap( xMin, yMin, xMax, yMax, xoff, yoff, mx, my, camX, camY ) -- TODO: Draw to RT? I don't see the map ever being big enough where this isn't worth it, though.
	local xm =floor( xMin )
	local ym =floor( yMin )
	local xmx = mceil( xMax )
	local ymx = mceil( yMax )
	
	audio.setCamPos( camX, camY )

	local sx = (panel.w / 16 / (xmx - xm+1))*16
	local sy = (panel.h / 16 / (ymx - ym+1))*16
	if mx then
		--mx = mx + sx
		--my = my + sy
	end
	local genx,geny
	if mx then
		genx = (mx - xoff*sx)/sx
		geny = (my - yoff*sy)/sy
		
	end
	--print(sx,sy)
	local z = 1
	local lvl = level
	--local level = level.turf
	-- Clear visibility
    fov.clearVisibility( z, xMin, xMax, yMin, yMax )
	-- Mark visible shit with rays
	fov.lightTraceToBorder( ply.x, ply.y, z, xMin, xMax, yMin, yMax )
	for x = xm - 1, xmx + 1 do
		for y = ym - 1, ymx + 1 do
			--print(sx,sy)
            local turf = level:getTurf( x, y, z )
            --if turf and turf.contents then print":D" end
            --if turf then turf.visible = visibilityCheck( camX, camY, x, y ) end
            if turf and (turf.visible or NOCLIP) then
                if not turf.icon then error(turf.path or "fuck: " .. tostring(turf.name)) end
                
                dmi.render( turf.icon, turf.icon_state, floor(xoff*sx + (x-1) * sx), floor(yoff*sy + (y-1) * sy), turf.dir, mceil(sx)/32 * turf.icon.dmwidth, mceil(sy)/32 * turf.icon.dmheight, level:getTurf(x,y,z).rng, turf.color)
            end
		end
	end
	for x = xm - 1, xmx + 1 do
		for y = ym - 1, ymx + 1 do
			--print(sx,sy)
            local turf = level:getTurf(x,y,z)
            --if turf and turf.contents then print":D" end
            if turf and (not genx or turf.visible or NOCLIP) then
                if turf.contents then
                    --print'turf has contents'
                    for k, v in pairs( turf.contents ) do
                        if v.icon then
                            v:render( floor(xoff*sx + (x-1) * sx), floor(yoff*sy + (y - 1) * sy), sx, sy )
                        end
                    end
                end
			end
		end
	end
    -- pretty lines
	--fov.debugTraceToBorder( ply.x, ply.y, z, xMin, xMax, yMin, yMax, xoff, yoff, sx, sy )
	--[[
	
	for k, v in pairs( lvl.entities ) do
		if v.icon and v.x >= xm and v.x <= xmx + 1 and v.y >= ym and v.y <= ymx + 1 then
			v:render(  floor(xoff*sx + (v.x-1) * sx), floor(yoff*sy + (v.y-1) * sy), sx, sy )
		end
	end]]
	
	if mx then
		return genx, geny, sx, sy
	end
end

--[[local activebox = gui.new('textbox')
activebox:dock(DOCK_TOP)
activebox:setText('/turf/unsimulated/space')
local activeTurf = turf.unsimulated.space
function activebox:onenter(val)
	if(not pathturf[val]) then
		self:deny()
		self:setText(activeTurf.__TURF.__index.path)
	else activeTurf = pathturf[val] end
end]]

local zoom = 15
local x, y = 0, 60
local down = {}
local lastMove = 0

function panel:draw()
    -- JUST
	local doit
	local mvX, mvY = 0, 0
	if down[119] then
		mvY = -1
	elseif down[115] then
		mvY = 1
	end
	if down[97] then
		mvX = -1
	elseif down[100] then
		mvX = 1
	end
	if (mvX ~= 0 or mvY ~= 0) and ply and not net.isConnected() then
		ply:Move( mvX, mvY )
	elseif (mvX ~= 0 or mvY ~= 0) and net.isConnected() and ply and (lastMove < system.getTime()) then
		net.sendToServer( C2S_Move, {x = mvX, y = mvY} )
		lastMove = system.getTime() + 0.1
	end
	if ply then
		x = ply.x - zoom/2 - 0.5 + ply.icon_x/32
		y = ply.y - zoom/2 - 0.5 + ply.icon_y/32
	end
	if not net.isConnected() or net.isHosting() then
		for k, v in pairs( level.entities ) do
			if( v.Update ) then v:Update() end
		end
		local deleted = false
		while not deleted do
			deleted = true
			for k, v in pairs( level.entities ) do
				if( v.markedForDeletion ) then
					deleted = false
					for k2, v2 in pairs( v.loc.contents ) do
						if v2 == v then table.remove( v.loc.contents, k2 ) break end
					end
					table.remove( level.entities, k )
					if net.isHosting() then
						net.broadcast( S2C_EntRemove, {id = v.id} )
					end
					break
				end
			end
		end
	else
		local deleted = false
		while not deleted do
			deleted = true
			for k, v in pairs( level.entities ) do
				if( v.markedForDeletion ) then
					deleted = false
					for k2, v2 in pairs( v.loc.contents ) do
						if v2 == v then table.remove( v.loc.contents, k2 ) break end
					end
					table.remove( level.entities, k )
					break
				end
			end
		end
	end
	if not ply then return end
	local mx, my, w, h = renderMap( floor(x) + 1, floor(y) + 1, floor(x) + zoom, floor(y) + zoom, -x, -y, self.mx, self.my, ply.x, ply.y )
	if mx then
		mx, my = mceil(mx), mceil(my)
		self.cx, self.cy = mx, my
		--surface.setDrawColor( 255, 128, 0 )
		--surface.drawRect( mx, my, w, h )
		--surface.setTextColor( 255, 255, 255 )
		local turf = level.turf[1]
		
		turf = turf and turf[mx]
		turf = turf and turf[my]
		
		
		if turf and turf.visible then
			if turf.contents then turf = turf.contents[1] or turf end
			surface.drawText( turf and ((turf.name or '') .. "|" .. ((turf.dir or 's')) or "") .. "|" .. turf.path .. "|" .. tostring(turf.visible), 0, self.h - 16 )
			surface.setDrawColor(255, 128, 0)
			surface.drawRect( (mx * w - w) - x * w, (my * h - h) - y * h, w, h )
		else self.cx = nil end
	else self.cx = nil end
	if doit then
		if self.depressed then
			if (self.ox ~= self.cx or self.oy ~= self.cy) and self.cx then

				level:setTurf( self.cx, self.cy, 1, activeTurf )
				self.ox = self.cx
				self.oy = self.cy
			end
		end
	end

end

local sdl = require'lib.sdl2'
local tween = require'lib.tween'
NOCLIP = false
function panel:onkeypress( k, mod, rep )
	if not rep and bind.onKeyDown( k ) then  return end
	if( k == sdl.KEY_t ) then
		local sayDialog = gui.new( 'frame', panel )
		sayDialog:setTitle( "Say..." )
		sayDialog:setSize( 400, 75 )
		sayDialog:center()
		sayDialog:makePopup()
		local entry = gui.new( 'textbox', sayDialog )
		entry:dock( DOCK_TOP )
		gui.setFocus( entry )
		function entry:onenter(msg)
			say(msg)
			sayDialog:remove()
			gui.setFocus(panel)
		end
	elseif( k == sdl.KEY_v ) then
		NOCLIP = not NOCLIP
	elseif( k == sdl.KEY_e ) then
		level:explode( ply.x, ply.y, ply.z )
	elseif( k == sdl.KEY_KP_PLUS ) then
		zoom = zoom - 1
	elseif k == sdl.KEY_KP_MINUS then
		zoom = zoom + 1
	else
		down[k]=true
	end

	--if k == 114 then os.exit(0) end
end

function panel:onmousemove( x, y )
	self.mx = x
	self.my = y
	if self.placing then
		if (self.ox ~= self.cx or self.oy ~= self.cy) and self.cx then

			level:setTurf( self.cx, self.cy, 1, activeTurf )
			self.ox = self.cx
			self.oy = self.cy
		end
	end
end

function panel:onmousedown( btn, x, y )
	if btn == 1 and self.cx then
	local mx, my, w, h = renderMap( floor(x) + 1, floor(y) + 1, floor(x) + zoom, floor(y) + zoom, -x, -y, self.mx, self.my, ply.x, ply.y )
		--level:setTurf( self.cx, self.cy, 1, activeTurf )
		local t = level.turf[ 1 ][ self.cx ][ self.cy ]
		if t and t.contents then
			for k, v in pairs( t.contents ) do
				if v.Click then
					v:Click(ply)
				end
			end
		end
		self.ox = self.cx
		self.oy = self.cy
		--self.placing = true
	elseif btn == 3 and self.cx then
		local e = level:newEntity( "/obj/machinery/doors/airlock" )
		if e then
			e:setpos( self.cx, self.cy, 1 )
		end
	elseif btn == 2 and self.cx then
		local e = level:newEntity( "/obj/machinery/turret" )
		if e then
			e:setpos( self.cx, self.cy, 1 )
		end
	end
end

function panel:onmouseup( btn, x, y )
	self.placing = false
end

function panel:onscroll( sx, sy )
	zoom = zoom + sy
	x = x - sy / 2
	y = y - sy / 2
end

function panel:onkeyrelease(k)
	down[k]=false
	if bind.onKeyUp( k ) then return end
end

local console=require'console'
console.add("host", function(ply, _, args)
	net.host('*')
	print("Hosting...")
end, "Hosts a server")
console.add("connect", function(ply, _, args)
	print("Connecting...")
	net.connect("127.0.0.1",7777)
end, "Hosts a server")
console.add("say", function(_,_,_,raw)
	if( #raw > 0 ) then
		say(raw)
	end
end, "Says something." )

function net.OnClientAccepted( c )
	for k, v in pairs( level.entities ) do
		c:send( S2C_NewEntity, {type = v.typeid, x = v.x, y = v.y, id = v.id or 0} )
	end
	local them = level:newEntity( "/obj/mob/human" )
	c.mob = them
	for k, v in pairs( level.entities ) do
		if( v.path == "/obj/spawnpoint" ) then
			them:setpos( v.x, v.y, v.z )
			break
		end
	end
    --c:send( S2C_NewEntity, {path = them.path, x = them.x, y = them.y, id = them.id or 0} )
	c:send( S2C_EyeAttach, {id=them.id} )
end

function net.OnConnected()
	level:clearEntities()
	print("PRECONNECT ENTS CLEARED")
end

function net.onClientDisconnected( client )
	client.mob:remove()
end

net.definePacket( "S2C_NewEntity", {{'type',NET_INT}, {'x', NET_INT}, {'y', NET_INT}, {'id', NET_INT}}, function(data)
    
	local ent = level:newEntity( data.type, true )
	
	ent:setpos( data.x, data.y, 1 )
	ent.id = data.id
	if( ent.id == ply ) then
		ply = ent
	end
end, nil, true )

net.definePacket( "S2C_EyeAttach", {{'id', NET_INT}}, function( data )
	ply = level:entByID( data.id ) or data.id
	print( "Attached to ", ply, ply.id, ply.x, ply.y )
end, nil, true )

net.definePacket( "S2C_EntPos", {{'id', NET_INT}, {'x', NET_INT}, {'y', NET_INT}, {'z', NET_INT}}, function( data )
	local ent = level:entByID( data.id )
	if ent then ent:setpos( data.x, data.y, data.z ) else print"???" end
end, nil, true )

net.definePacket( "S2C_EntRemove", {{'id', NET_INT}}, function( data )
	local ent = level:entByID( data.id )
	if ent then ent:remove() end
end, nil, true )

net.definePacket( "S2C_EntMove", {{'id', NET_INT}, {'x', NET_INT}, {'y', NET_INT}}, function( data )
	local ent = level:entByID( data.id )
	if not ent then
		print( "Got invalid entmove packet (" .. data.id .. ")" )
	else
		ent:Move( data.x, data.y, true, true )
	end
end, nil, true )

net.definePacket( "C2S_Move", {{'x', NET_INT}, {'y', NET_INT}}, function( client, data )
	local ent = client.mob
	ent:Move( data.x, data.y )
end, nil, true )

net.definePacket( "S2C_EntCommand", {{'id', NET_INT}, {'cmd', NET_BYTE}}, function( data, buffer )
	local ent = level:entByID( data.id )
    if not ent then return end
	if data.cmd == ECMD_FLICK_STATE then
		--flick w/o icon change
		ent:flick( buffer:ReadString(), nil, true )
	elseif data.cmd == ECMD_FLICK_ICONSTATE then
		--flick w/ icon change
		ent:flick( buffer:ReadString(), buffer:ReadString(), true )
	elseif data.cmd == ECMD_ROTATE then
		ent.rot = buffer:ReadFloat()
	end
end, nil, true )

net.definePacket( "NET_ChatMessage", {{'message',NET_STRING}, {'id', NET_INT}}, function(client, data)
	client.mob:say( data.message )
end, function( data )
	level:entByID( data.id ):say( data.message, true )
end, true )

net.definePacket( "C2S_UserCommand", {{'buttons', NET_INT}}, function( client, data )
	
end, true )

level = map.load('maps/giddyup.dmm')
_G.level = level
if net.isHosting() then
	ply = level:newEntity( "/obj/mob/human" )
	_G.ply = ply
	for k, v in pairs( level.entities ) do
		if( v.path == "/obj/spawnpoint" ) then
			ply:setpos( v.x, v.y, v.z )
			break
		end
	end
end
