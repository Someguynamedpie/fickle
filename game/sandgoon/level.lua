local turf,turfPaths = unpack(require'sandgoon.turf')--todo: cleanup

local M = {}
local meta = {} meta.__index = meta
function M.new( w, h, z )
	local level = setmetatable( {}, meta )
	level.turf = {}
	level.entities = {}
	
	for z = 1, z or 1 do
		for x = 1, w do
			for y = 1, h do
				level.turf[ z ]      = level.turf[ z ] or {}
				level.turf[ z ][ x ] = level.turf[ z ][ x ] or {}
				level:setTurf( x, y, z, turf.unsimulated.space, true )
			end
		end
	end
	level.width = w
	level.height = h
	level.depth = z
	return level
end
local dirs = {
	[1] = 'n',
	[2] = 's',
	[4] = 'e',
	[8] = 'w',

	[5] = 'ne',
	[6] = 'se',
	[9] = 'nw',
	[10] = 'sw'
}
local ents, paths = unpack(require'sandgoon.ents')
local cid = 0
function meta:entByID( id )
	for k, v in pairs( self.entities ) do
		if v.id == id then return v end
	end
end
function meta:newEntity( path, lon )
	if lon or net.isHosting() then
		local meta
		if( type( path ) == 'number' ) then
			meta = paths.getByID( path )
		else
			meta = paths[ path ]
		end
		if not meta.typeid then error"????" end
		if not meta then
			error( "Attempt to place invalid entity " .. path )
		end
		local ent = setmetatable( {world = self}, meta )
		cid = cid + 1
		ent.id = cid
		table.insert( self.entities, ent )
		if ent.new then ent:new() end
		if net.isHosting() then
			net.broadcast( S2C_NewEntity, {type = meta.typeid, x = ent.x or 0, y = ent.y or 0, id = ent.id or 0} )
		end
		return ent
    end
end

function meta:explode( x, y, z )
	local ent = self:newEntity( "/obj/explosion" )
	if not ent then return end
    ent:setpos( x, y, z )
end

function meta:update()
	
end
function meta:setTurf( x, y, z, turf, nocheck, nogetter )
	if not nogetter then turf = turf.__TURF end
	if not nocheck then--Efficiency.
		if not self.turf[z] or not self.turf[z][x] or not self.turf[z][x][y] then error( "Coords " .. x .. ', ' .. y .. ', ' .. z .. ' invalid.' ) end
		local prev = self.turf[ z ][ x ][ y ]
		if prev.del then prev:del() end
	end
	--print(turf.__index)
	local et = turf
	local turf = setmetatable( {}, turf ) -- gc hell, turf changing is not efficient.
	if turf.new then
		turf:new()
	end
	if not self.turf[z] or not self.turf[z][x] then
		error( "Invalid Turf Coordinates: " .. x .. ", " .. y .. ", " .. z )
	end
	turf.rng = turf.rng or math.random()
	self.turf[ z ][ x ][ y ] = turf
end
local icons = require'sandgoon.icons'.loadDMI
function M.load( path )
	local hdl = io.open( path, 'rb' )
	local turfs = {}
	local objects = {}
	local len = 0
	local start = false
	local lvl
	local lines = {}
	for line in hdl:lines() do
		if not line:find'\r' then line = line .. '\r' end
		local key, list = line:match('"(.-)" = %((.-)%)\r')

		if not key then
			--print(line,line=='(1,1,1) = {"')
			if(line == '(1,1,1) = {"\r') then
				start = true
			elseif line == '"}\r' then
				start = false
			elseif start then
				table.insert( lines, line:sub(1,-2) )
				--print('insert',line)
			end
		else

			len = #key
			local theTurf = list--list:match("(/turf/.-)[,)]")
			
			local objs
			if theTurf then
				if theTurf:find',' and not theTurf:find'{' then
					local split = list:split(",")
					for k, v in pairs(split) do
						if(v:sub(1,5) == '/turf') then
							theTurf = v:match("([^,)]+)")
						elseif( v:sub(1,4) == "/obj" or v:sub(1,4) == "/mob" ) then
							if v:sub(1,4) == "/mob" then
								v = "/obj" .. v
							end
							if not objs then objs = {} end
							table.insert( objs, v:match("([^,)]+)") )
						end
					end
				end
				local tbl = {}
				theTurf = theTurf:gsub('/airless','')
				local idx = theTurf:find'{'
				objects[ key ] = objs
				if theTurf:find'{' then
					local str = theTurf:sub(idx+1)
					theTurf = theTurf:sub(1,idx-1)
					for k, v in str:gmatch("(.-)=(.-)[;}]") do
						k = k:match("^%s*(.-)%s*$")
						if(v:find("'") or v:find('"')) then
							v=v:sub(3,-2)
						end
						if k == "icon" then
							v = icons(v)
						elseif k == "dir" then
							v = dirs[tonumber(v:sub(2))]
						end
						tbl[k]=v
					end
					--if(key=='aar') then print':D'end
					--print(key,theTurf)
					turfs[key] = {__index=setmetatable( tbl, turfPaths[theTurf] )}

				else turfs[key] = turfPaths[theTurf] end
				if not turfPaths[theTurf] then error("couldnt find " .. theTurf) end
			end
		end
	end
	hdl:close()
	if #lines > 0 then
		local w = (#lines[1])/len
		lvl = M.new(w, #lines, 1)

		for y = 1, #lines do
			local line = lines[y]
			for x = 1, #line, len do
				local str = line:sub(x, x+(len-1))
				--[[print((x),x+(len-1),str,turfs[str].path)
				local mt = setmetatable({},turfs[str])
				print(getmetatable(turfs[str]).__index)
				if not turfs[str] then
					error'why'
				end]]
				
				if turfs[str] then
					lvl:setTurf((x+len-1)/len,y,1,turfs[str],true,false)
				else error(str) end
				if objects[str] then
					for k, v in pairs( objects[ str ] ) do
						local ent = lvl:newEntity( v, true )
						ent:setpos( x, y, 1 )
					end
				end
			end
		end
	else error'no level' end
	return lvl
end
local round = math.round
function meta:getTurf( x, y, z )
	if( x > 0 and x <= self.width and y > 0 and y <= self.height and z > 0 and z <= self.depth ) then
		return self.turf[z][round(x)][round(y)]
	end
end

function meta:clearEntities()
	local turf = self.turf[1]
	for k, v in pairs( turf ) do
		for k2, v2 in pairs( v ) do
			v2.contents = nil
		end
	end
	self.entities = {}
end
return M
