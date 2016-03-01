local icons = require'sandgoon.icons'.loadDMI
ECMD_FLICK_STATE = 0
ECMD_FLICK_ICONSTATE = 1
ECMD_ROTATE = 2
local function E(t) t.TYPE = 'obj' return t end
local M = E{
	--icon, icon_state
	dir = 's',
	icon_frame = 1,
	icon_lastframe = nil,
	x = 1,
	y = 1,
	z = 1,
	lastmove = 0,
	movedelay= 0,
	icon_x = 0,
	icon_y = 0,
	opaque = false,
	invulnerable = true
}--todo: zlevel array of entities
local cardinal = {
	['n'] = {0, -1},
	['s'] = {0, 1},
	['e'] = {1, 0},
	['w'] = {-1, 0},
}
function M:remove()
	self.markedForDeletion = true
end
function M:ecmd( cmd, exclude )
	if type( cmd ) == 'number' then
		return net.start( S2C_EntCommand, {id = self.id, cmd = cmd} )
	else
		return net.finish( cmd, nil, exclusion )
	end
end
local system = require'system'
local tween  = require'lib.tween'
function M:Move( x, y, nodelay, netbypass )
	if net.isConnected() then
		if not netbypass then return end
	end
	
	if not nodelay and self.lastmove + self.movedelay > system.getTime() then return end
	if self.health and self.health <= 0 then return end
	if net.isHosting() then
		net.broadcast( S2C_EntMove, {id = self.id, x = x, y = y} )
	end
	local mult = 1
	if x ~= 0 and y ~= 0 then
		mult = math.sqrt(2)
		
		if not NOCLIP then
			local t = self.world:getTurf( self.x + x, self.y, self.z )
			if( not t:Enter() ) then
				t = self.world:getTurf( self.x, self.y + y, self.z )
				if( not t:Enter() ) then return end
			end
		end
	end
	
	for k, v in pairs( cardinal ) do
		if( v[1] == x and v[2] == y ) then
			self.dir = k
		end
	end
	local tgtTurf = self.world:getTurf( self.x + x, self.y + y, self.z )
	if( tgtTurf and (NOCLIP or tgtTurf:Enter( self )) ) then
		local built = {}
		if x == 1 or x == -1 then
			built['icon_x'] = 0
			self.icon_x = -32 * x
		end
		if y == 1 or y == -1 then
			built['icon_y'] = 0
			self.icon_y = -32 * y
		end
        -- if we're moving diagonally slow us down
        local time = math.min(self.movedelay, .5)
        local timediff = time * mult - time
        tween.new( self, built, time * mult, 'linear' )
        self:setpos( self.x + x, self.y + y, self.z, true )
        self.lastmove = system.getTime() + timediff
	end
end
function M:Touch()
end
function M:Click( mob )
	if mob.health and mob.health <= 0 then return end
	if( self:distance( mob ) <= 2 ) then
		if self.takeDamage then
			self:takeDamage( self, math.random( 1, 3 ) )
			if( self.path:find( "mob" ) ) then
				self:takeDamage( self, math.random( 5, 15 ) )
				mob:emitSound( "sound/weapons/punch" .. math.random(1,4) .. ".ogg" )
				world( color_green, mob.name, color_red, " punches ", color_green, self.name, color_red, "!\n" )
			else
				mob:emitSound( "sound/weapons/genhit" .. math.random(1,3) .. ".ogg" )
				world( color_green, mob.name, color_red, " hit the ", color_green, self.name, color_red, "!\n" )
			end
			
		end
	end
end
function M:flick( state, newIcon, xmitted )
	if not net.isHosting() and not xmitted then return end
	self.icon_frame = system.getTime()
	self.icon_state = state
	if newIcon then self.icon = icons(newIcon) end
	if net.isHosting() then
		if newIcon then
			self:ecmd( self:ecmd( ECMD_FLICK_ICONSTATE ):WriteString( state ):WriteString( newIcon ) )
		else
			self:ecmd( self:ecmd( ECMD_FLICK_STATE ):WriteString( state ) )
		end
	end
end
function M:emitSound( path, xmitted )
	if not net.isHosting() and not xmitted then return end
	local src = audio.loadSource( path, nil )
	src:setPos( self.x, self.y )
	src:play()
end
function M:setpos( x, y, z, nosend )
	local turf = self.world.turf[self.z][self.x][self.y]
	if turf.contents then
		for i = 1, #turf.contents do
			if turf.contents[i] == self then
				table.remove( turf.contents, i )
				break
			end
		end
	end
	z = z or 1
	x = x or 1
	y = y or 1
	if not self.world.turf[z] or not self.world.turf[z][x] or not self.world.turf[z][x][y] then self:remove() return end
	self.x = x
	self.y = y
	self.z = z
	
	local turf = self.world.turf[self.z][self.x][self.y]
	turf.contents = turf.contents or {}
	table.insert( turf.contents, self )
	self.loc = turf
	if net.isHosting() and not nosend then
		net.broadcast( S2C_EntPos, {id = self.id, x = self.x, y = self.y, z = self.z} )
	end
	
end
function M:distance( other )
	return math.sqrt( (other.x - self.x)^2 + (other.y - self.y)^2 )
end
local dmi = require'video.dmi'
local mfloor = math.floor
local mceil = math.ceil
function M:render(x, y, sx, sy)
	local scx = sx/32
	local scy = sy/32
	dmi.render( self.icon, self.icon_state, x + self.icon_x*scx, y + self.icon_y*scy, self.dir, scx * self.icon.dmwidth, scy * self.icon.dmheight, self.icon_frame, nil, self.rot )
end
M.machinery = E{doors = E{}}
local audio = require'audio'
M.machinery.doors.airlock = E{
	glass = E{icon = 'icons/obj/doors/Doorcom-glass.dmi', opaque = false, transparent = true},
	maint = E{icon = 'icons/obj/doors/Doormaint.dmi'},
	icon = 'icons/obj/doors/Doormed.dmi',
	icon_state = 'door_closed',
	name = "airlock",
	dense = true,
	opaque = true,
	opening = false,
	isopen = false,
	open = function( self )
		if self.opening or self.isopen then return end
		self.opening = true
		self:flick( "door_opening" )
		self:emitSound( "sound/machines/airlock_swoosh_temp.ogg" )
		self.opaque = false
		fickle.addTimer( "airlock" .. math.random(), 0.5, 1, function()
			self:flick( "door_open" )
			self.opening = false
			self.dense = false
			self.isopen = true
		end )
		fickle.addTimer( "airlock" .. math.random(), 5, 1, function()
			self:close()
		end)
	end,
	Touch = function(self)
		if self.isopen then return end
		self:open()
	end,
	close = function( self )
		if self.opening or not self.isopen then return end
		self.opening = true
		self:flick( "door_closing" )
		self:emitSound( "sound/machines/airlock_swoosh_temp.ogg" )
		
		self.dense = true
		fickle.addTimer( "airlock" .. math.random(), 0.5, 1, function()
			self:flick( "door_closed" )
			self.opening = false
			self.isopen = false
			if not self.transparent then
				self.opaque = self.transparent and false or true
			end
		end )
	end,
}
local dirs = {
	[5] = 'nw',
	[4] = 'n',
	[6] = 'w',
	[7] = 'sw',
	[0] = 's',
	[1] = 'se',
	[2] = 'e',
	[3] = 'ne',
	[8] = 's'
}
local function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
M.machinery.turret = E{
	name = "defense turret",
	icon = 'icons/obj/turrets.dmi',
	icon_state = "target_prism",
	team = 0,
	lastfire = 0,
	health = 20,
	dense = true,
	invulnerable = false,
	takeDamage = function( self, inflictor, dmg )
		self.health = self.health - dmg
		if self.health >= 5 then
			self:flick( "target_prism" )
			return true
		elseif self.health >= 0 then
			self:flick( "destroyed_target_prism" )
			return true
		elseif self.health <= 0 then
			self.world:explode( self.x, self.y, self.z )
			self:remove()
			return true
		end
	end,
	Update = function( self )
		if self.health < 0 then return end
		for k, v in pairs( self.world.entities ) do
			if( v.path == '/obj/mob/human' and self:distance(v) <= 5 and v.dense ) then
				self.dir = dirs[ round( (math.deg(math.atan2(self.x-v.x,self.y-v.y)) + 180 ) / (360/8) )]
				if self.lastfire < system.getTime() then
					self.lastfire = system.getTime() + 2
					local e = self.world:newEntity( "/obj/projectile/bolt" )
					if e then
						e:setpos( self.x, self.y, self.z )
						e:setup( v.x, v.y )
						e.owner = self
					end
					self:emitSound( "sound/misc/TaserOLD.ogg" )
				end
			end
		end
	end,
}
M.projectile = E{
	vx = 0, vy = 0,
	dir = 'n',
	icon = 'icons/obj/projectiles.dmi',
	passed = 0,
	setup = function( self, x, y )
		local ang = math.atan2( self.x-x, self.y-y )
		self.vx = math.sin(ang) * 4
		self.vy = math.cos(ang) * 4
		self.rot = 180 - math.deg( ang )
		self:ecmd( self:ecmd( ECMD_ROTATE ):WriteFloat( self.rot ) )
	end,
	Update = function(self)
		self.icon_x = self.icon_x - self.vx
		self.icon_y = self.icon_y - self.vy
		
		if math.abs( self.icon_x ) >= 32 then
			self:setpos( self.x + round( self.icon_x/32 ), self.y, self.z )
			self.icon_x = self.icon_x - round( self.icon_x/32 ) * 32
			self.passed = self.passed + math.abs( self.icon_x/32 )
		end
		if math.abs( self.icon_y ) >= 32 then
			self:setpos( self.x, self.y + round( self.icon_y/32 ), self.z )
			self.icon_y = self.icon_y - round( self.icon_y/32 ) * 32
			self.passed = self.passed + math.abs( self.icon_y/32 )
		end
		if( self.passed >= 6 or not self.loc or self.loc.dense) then self:remove() elseif self.loc then
			for k, v in pairs( self.loc.contents ) do
				if( v ~= self.owner and not v.invulnerable and v.dense and v:takeDamage( self, 5 ) ) then
					world( color_green, v.name, color_red, " is hit by the ", color_green, self.name, color_red, "!\n" )
					self:remove()
					return
				elseif( v.dense and v ~= self.owner ) then self:remove() return end
			end
		end
		
		
	end,
		
	bolt = E{
		icon_state = 'laser',
		name = "Laser Beam"
	}
}
M.moba = E{}
M.moba.mainframe = E{
	name = "Mainframe Core",
	icon = 'icons/mob/ai.dmi',
	icon_state = "ai",
	desc = "Protect this at all costs!"
}
M.spawnpoint = E{
	name = "spawnpoint",
	--icon = 'icons/obj/doors/Door1.dmi',
	icon_state = "door1"
}

M.mob = E{health = 100, invulnerable = false, onHurt = function() return true end}
function M.mob:takeDamage( src, dmg )
	self.health = self.health - dmg
	return self:onHurt( src, dmg )
end
function M.mob:say( str, force )
	if net.isConnected() and not force then
		return
	end
	if net.isHosting() then
		net.broadcast( NET_ChatMessage, {id = self.id, message = str} )
	end
	if(str:sub(1,1) == "*") then
		self:emote( str:sub(2) )
	else
		world( color_green, self.name, color_white, " says, ", color_green, '"', str, '"\n' )
	end
end
function M.mob:emote( cmd )
	if cmd == "flip" then
		self.rot = 0
		tween.new( self, {rot = 360}, .4, "linear" )
		world( color_green, self.name, color_white, " did a flip!\n" )
	elseif cmd == "fart" then
		world( color_green, self.name, color_white, " farted!\n" )
		self:emitSound( "sound/misc/poo2.ogg", true )
		local turf = self.loc
		if turf then
			turf.color = Color(150,75,0)
		end
    elseif cmd == "suicide" then
        if self.health <= 0 then return end
		world( color_red, self.name, color_red, " is holding his breath! Looks like he's trying to gib!\n" )
        self:takeDamage( self, 100 )
		local turf = self.loc
		if turf then
			turf.color = Color(255,0,0)
		end
    elseif self.type ~= "/obj/mob/human" then
		world( color_red, self.name, " ", cmd, "\n" )
	end
end

M.mob.human = E{
	name = "Player",
	icon = "icons/mob/human.dmi",
	icon_state = "body_m",
	movedelay = .2,
	health = 100,
	dense = true,
	gib = function(self)
		self:flick( "gibbed-h", 'icons/mob/mob.dmi' )
		self:emitSound( "sound/effects/gib.ogg" )
		self.dense = false
		self.health = 0
		fickle.addTimer( "respawn" .. math.random(), 1, 1, function()
			for k, v in pairs( self.world.entities ) do
				if( v.path == "/obj/spawnpoint" ) then
					self:setpos( v.x, v.y, v.z )
					break
				end
			end
			
			self.dense = true
			self:flick( "body_m", 'icons/mob/human.dmi' )
			self.health = 100
		end )
		world( color_green, self.name, color_red, " explodes in a shower of gibs!\n" )
	end,
	onHurt = function( self, dmger, dmg )
		if self.health <= 0 then
			self:gib()
		end
		return true
	end
}

M.effect = E{}
M.effect.voidtiles = E{
	icon = 'icons/effects/3dimension.dmi',
	name = "void tiles",
	new = function(self)
		self.icon_state = "floattiles" .. math.random(1,6)
	end,
	dense = false
}
M.effect.telepad = E{
	icon = 'icons/obj/stationobjs.dmi',
	name = "telepad",
	icon_state = "pad0",
	dense = false,
	opaque = false
}
M.effect.girder = E{
	icon = 'icons/obj/structures.dmi',
	name = 'girder',
	icon_state = 'girder'
}
M.effect.girder = E{
	icon = 'icons/obj/structures.dmi',
	name = 'girder',
	icon_state = 'girder',
	dense = true
}
M.effect.lattice = E{
	icon = 'icons/obj/structures.dmi',
	name = 'lattice',
	icon_state = 'lattice'
}
M.table = E{
	icon = 'icons/obj/table.dmi',
	name = "table",
	icon_state = "0",
	dense = true
}
M.window = E{
	icon = 'icons/obj/window_pyro.dmi',
	icon_state = "mapwin_r",
	color = Color( 30, 30, 100 ),
	dense = true
}


M.mob.critter = E{icon = 'icons/misc/critter.dmi'}

M.mob.critter.eyething = E{
	name = "floating thing",
	icon_state = 'floateye',
	movedelay = 5,
	Update = function(self)
		self.movedelay = 5 + (math.random() * 2 - 1 )
		self:Move( math.random( -1, 1 ), math.random( -1, 1 ) )
	end
}
local targetPhrases = {
	"help us please!",
	"h-hey you.. w-what are you doing",
	"you can h-help us!",
	"how did you get here!"
}
local wanderPhrases = {
	"they said nothing would go wrong!",
	"why didn't they listen!",
	"shut it down!",
	"It hurts, oh God, oh God.",
	"I warned them. I warned them the system wasn't ready.",
	"Cut the power! It's about to go critical, cut the power!"
}

local function capimax(str)
	local ret = ""
	for i = 1, #str do
		ret = ret .. (i%2 == 0 and str:sub(i,i):upper() or str:sub(i,i):lower())
	end
	return ret
end
M.mob.critter.aberration = E{
	name = "transposed particle field",
	icon_state = "aberration",
	movedelay = 2,
	absorbwait = 0,
	Update = function(self)
		if not self.target or not self.target.dense then
			self.target = nil
			for k, v in pairs( self.world.entities ) do
				if( v.path == '/obj/mob/human' and self:distance(v) <= 3 and v.dense ) then
					self:say( "*lunges towards " .. v.name .. "!" )
					self.target = v
					break
				end
			end
		end
		if self.target and self.target:distance( self ) > 3 then self.target = nil end
		if self.target and self.absorb and self.absorb < system.getTime() and self.target:distance( self ) <= 1 then
			self.target:gib()
			self.target = nil
			self.absorb = nil
			self.absorbwait = system.getTime() + 2
		elseif self.absorb and (not self.target or self.absorb > system.getTime()) and (not self.target or self.target:distance( self ) > 1) then
			self.absorb = nil
			self.absorbwait = system.getTime() + 2
		end
		
		if self.target then
			self.movedelay = 0.3
			local xdir = math.max( math.min( self.target.x - self.x, 1 ), -1 )

			local ydir = math.max( math.min( self.target.y - self.y, 1 ), -1 )
			self:Move( xdir, ydir )
			if( self.target:distance( self ) <= 1.9 and not self.absorb ) then
				if self.absorbwait and system.getTime() > self.absorbwait then
					self:say( "*begins to absorb " .. self.target.name .. "!" )
					self.absorb = system.getTime() + 3
				end
			end
		else
			self.movedelay = 2
			self:Move( math.random( -1, 1 ), math.random( -1, 1 ) )
		end
		
	end
}
M.mob.critter.scientist = E{
	name = "transposed scientist",
	icon_state = "crunched",
	movedelay = 2,
	lasthit = 0,
	takeDamage = function( self, inflictor, dmg )
		self.health = self.health - dmg
		if self.health <= 0 then
			self:remove()
			local ghost = self.world:newEntity( "/obj/mob/critter/aberration" )
			if ghost then ghost:setpos( self.x, self.y, self.z ) end
			return true
		end
	end,
	Update = function(self)
		if not self.target or not self.target.dense then
			self.target = nil
			for k, v in pairs( self.world.entities ) do
				if( v.path == '/obj/mob/human' and self:distance(v) <= 5 and v.dense ) then
					self:say( capimax( targetPhrases[math.random(1,#targetPhrases)] ) )
					self.target = v
					break
				end
			end
		end
		if not self.nexttalk or self.target then self.nexttalk = system.getTime() + math.random( 10, 20 ) end
		if self.nexttalk < system.getTime() and not self.target then
			self:say( capimax( wanderPhrases[math.random(1,#wanderPhrases)] ) )
			self.nexttalk = system.getTime() + math.random( 10, 20 )
		end
		if self.target and (not self.target.dense or self.target:distance( self ) > 5) then self.target = nil end
		
		if self.target then
			
			self.movedelay = 0.3
			local xdir = math.max( math.min( self.target.x - self.x, 1 ), -1 )

			local ydir = math.max( math.min( self.target.y - self.y, 1 ), -1 )
			self:Move( xdir, ydir )
			if( self.target:distance( self ) <= 1.9 and self.lasthit < system.getTime() ) then
				self:say( "*hits " .. self.target.name .. "!" )
				self.target:takeDamage( self, math.random( 5, 15 ) )
				self:emitSound( "sound/weapons/punch" .. math.random(1,4) .. ".ogg" )
				
				self.lasthit = system.getTime() + 2 + math.random()
			end
		else
			self.movedelay = 2
			self:Move( math.random( -1, 1 ), math.random( -1, 1 ) )
		end
		
	end
}
M.explosion = E{
	name = "explosion",
	icon = 'icons/effects/hugeexplosion.dmi',
	icon_x = -17,
	icon_y = -120,
	new = function(self)
		self:flick( "explosion" )
		self:emitSound( "sound/effects/Explosion" .. math.random(1,2) .. ".ogg" )
		fickle.addTimer( "explode" .. self.id, 3.1, 1, function()
			self:remove()
		end )
	end
}
--[[[app]debug: door_closed
[app]debug: door_locked
[app]debug: door_opening
[app]debug: door_deny
[app]debug: door_closing
[app]debug: door_open
[app]debug: o_door_opening
[app]debug: o_door_closing
[app]debug: door_spark
[app]debug: panel_open
[app]debug: welded
[app]debug: NOTUSED
[app]debug: elights]]

local ID = 0
local M2 = {}
local easypath = {}
local rawashell = function(t,k) return rawget( t.__index, k ) or t.parent[ k ]end
local function metaify( t, iters, st, path, parent )
	iters = iters or 0
	for k, v in pairs( t ) do
		local path = path
		if( type( v ) == 'table' and v.TYPE == 'obj' ) then
			if v.icon then
				v.icon = icons(v.icon,v.log)
				if not v.icon then error("No icon.") end
			end
			v.typeid = ID
			setmetatable( v, {__index = t} )
			
			--[[local st = setmetatable( {__hack=v}, {__index=rawashell} )
			metaify( v, iters + 1, subtable2 )
			subtable[ k ] = st]]
			--if k == "mob" and path == "/obj" then
				--path = "/mob"
			--else
				path = path .. "/" .. k
			--end
			v.path = path
			io.write( ("| "):rep(iters) .. k .. "[" .. (v.icon and 'iconned' or 'uniconned') .. "]: " .. path .. " (id: " .. v.typeid .. ") \n" )
			local t = {__index = v, typeid = ID}
			subtable = {__ENT = t}
			st[ k ] = subtable
			easypath[path]=t
			ID = ID + 1
			metaify( v, iters + 1, subtable, path, t )
			
		end
	end

end
metaify( M, 0, M2, "/obj" )

function easypath.getByID( id )
	for k, v in pairs( easypath ) do
		if( v ~= easypath.getByID and v.typeid == id ) then
			return v
		end
	end
end


--assert(setmetatable({},M2.unsimulated.beach.sand.__TURF).icon)
return {M2, easypath}
