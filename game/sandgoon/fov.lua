local bresenham = require'util.bresenham'

local floor = math.floor
local round = math.round
local sqrt = math.sqrt
local abs = math.abs

--1: right
--2: left
--4: down
--8: up
local dirs = {
	[-1] = {[-1] = 10, [0] = 2, [1] = 6},
	[0] = {[-1] = 8, [0] = 0, [1] = 4},
	[1] = {[-1] = 9, [0] = 1, [1] = 5}
}
-- Returns the hitpos and normal
local function lightTrace( x0, y0, z, x1, y1, xoff, yoff, sx, sy )
	local lastx, lasty = x0, y0
    local nx,ny = lastx-x1, lasty-y1
    local length = sqrt(nx*nx+ny*ny)
    local roundnx = nx/length
    local roundny = ny/length
	for x,y in bresenham.enum( x0, y0, x1, y1 ) do
		local tile = level:getTurf( x, y, z )
		if not tile then return x,y,0,0 end
        -- first check if we moved diagonally
        local diffx,diffy = lastx-x, lasty-y
        if diffx ~= 0 and diffy ~= 0 then
            -- if we did we have to check if we passed through a diagonal gap
            local starboardTile = level:getTurf( x, y+diffy, z )
            local portTile = level:getTurf( x+diffx, y, z )
            if starboardTile and portTile then
                if starboardTile:isOpaque() and portTile:isOpaque() then
                    -- AHOY ICEBERGS
                    -- DOWN GOES THE TITANTIC
                    -- If we turn out to be a corner we should make the corner visible
                    if tile:isOpaque() and tile.visible == nil then
                        tile.visible = true
                    end
                    return x, y, diffx, diffy
                end
            end
        end
        if tile.visible == nil then
            tile.visible = true
        end
		if tile:isOpaque() then
			-- check nearby neighbors to determine wall structure
			local test = 0
			-- duuur no bitwise operators, not that it matters here
            -- ugh so many TABS
			for xd = -1, 1 do
				for yd = -1, 1 do
					if xd == 0 or yd == 0 then
						local tile2 = level:getTurf( x + xd, y + yd, z )
						if tile2 and tile2:isOpaque() then
                            -- I'VE COME SO FAR, TO LOSE IT ALL
							test = test + dirs[xd][yd]
						end
                        -- BUT IN THE END
					end
                    -- DOES IT EVEN MATTEeee
				end
                -- eeeer
			end
			nx,ny = lastx-x, lasty-y
			-- NO SWITCH STATEMENTS EITHER, THIS IS GETTING BETTER AND BETTER
			-- o - center
			-- . - neighbor
			-- > - ray direction (if relevant)

            --  8
            -- 1o2
            --  4
			
			--
			-- .o.
			--
			if test == 3 then
                nx = 0
			-- .
			-- o
			-- .
			elseif test == 12 then
                ny = 0
			--  .
			-- .o.
			--  ^
            elseif ny == 1 and test == 11 then
                nx = 0
			--  v
			-- .o.
			--  .
            elseif ny == -1 and test == 7 then
                nx = 0
			--  .
			-- .o<
			--  .
            elseif nx == 1 and test == 14 then
                ny = 0
			--  .
			-- >o.
			--  .
            elseif nx == -1 and test == 13 then
                ny = 0
            -- These lines make walls physically like ==D instead of ==O
            elseif roundnx < 0 and test == 2  then
                nx = 0
            elseif roundnx > 0 and test == 1  then
                nx = 0
            elseif roundny > 0 and test == 4  then
                ny = 0
            elseif roundny < 0 and test == 8  then
                ny = 0
            -- TODO: Literal corner cases... corners look like |  instead of | right now
            --                                                 O=            L=
            else
                nx = roundnx
                ny = roundny
            end
            tile = level:getTurf( x-round(nx), y-round(ny), z )
            if tile and not tile:isOpaque() then
                tile.visible = false
            end
			return x, y, nx, ny
		end
        nx, ny = lastx-x, lasty-y
		lastx, lasty = x, y
	end
    return x1, y1, 0, 0
end

-- Same as lightTrace, but draws debug lines, doesn't have documentation, and doesn't mark visuals.
local function debugTrace( x0, y0, z, x1, y1, xoff, yoff, sx, sy )
	local lastx, lasty = x0, y0
    local nx,ny = lastx-x1, lasty-y1
    local length = sqrt(nx*nx+ny*ny)
    local roundnx = nx/length
    local roundny = ny/length
	for x,y in bresenham.enum( x0, y0, x1, y1 ) do
        surface.setDrawColor( 255, 0, 0, 255 )
        surface.drawLine( xoff*sx + (x-0.5) * sx, yoff*sy + (y-0.5) * sy, xoff*sx + (lastx-0.5) * sx, yoff*sy + (lasty-0.5) * sy)
        local diffx,diffy = lastx-x, lasty-y
        if diffx ~= 0 and diffy ~= 0 then
            local starboardTile = level:getTurf( x, y+diffy, z )
            local portTile = level:getTurf( x+diffx, y, z )
            if starboardTile and portTile then
                if starboardTile:isOpaque() and portTile:isOpaque() then
                    return x, y, diffx, diffy
                end
            end
        end
		local tile = level:getTurf( x, y, z )
		if not tile then return x,y,roundnx,roundny end
		if tile:isOpaque() then
			local test = 0
			for xd = -1, 1 do
				for yd = -1, 1 do
					if xd == 0 or yd == 0 then
						local tile2 = level:getTurf( x + xd, y + yd, z )
						if tile2 and tile2:isOpaque() then
							test = test + dirs[xd][yd]
						end
					end
				end
			end
			nx,ny = lastx-x, lasty-y
			if test == 3 then
                nx = 0
			elseif test == 12 then
                ny = 0
            elseif ny == 1 and test == 11 then
                nx = 0
            elseif ny == -1 and test == 7 then
                nx = 0
            elseif nx == 1 and test == 14 then
                ny = 0
            elseif nx == -1 and test == 13 then
                ny = 0
            elseif roundnx < 0 and test == 2  then
                nx = 0
            elseif roundnx > 0 and test == 1  then
                nx = 0
            elseif roundny > 0 and test == 4  then
                ny = 0
            elseif roundny < 0 and test == 8  then
                ny = 0
            else
                nx = roundnx
                ny = roundny
            end
            surface.setDrawColor( 0, 0, 255, 255 )
            surface.drawLine( xoff*sx + (x-0.5) * sx, yoff*sy + (y-0.5) * sy, xoff*sx + (x+nx-0.5) * sx, yoff*sy + (y+ny-0.5) * sy)
			return x, y, nx, ny 
		end
        nx, ny = lastx-x, lasty-y
		lastx, lasty = x, y
	end
    return x1, y1, 0, 0
end

-- same as lightTrace but doesn't mark things visible or return normals
local function rayTrace( x0, y0, z, x1, y1 )
	local lastx, lasty = x0, y0
	for x,y in bresenham.enum( x0, y0, x1, y1 ) do
        -- first check if we moved diagonally
        local diffx,diffy = lastx-x, lasty-y
        if diffx ~= 0 and diffy ~= 0 then
            -- if we did we have to check if we passed through a diagonal gap
            local starboardTile = level:getTurf( x, y+diffy, z )
            local portTile = level:getTurf( x+diffx, y, z )
            if starboardTile and portTile then
                if starboardTile:isOpaque() and portTile:isOpaque() then
                    -- AHOY ICEBERGS
                    -- DOWN GOES THE TITANTIC
                    return x, y
                end
            end
        end
		local tile = level:getTurf( x, y, z )
		if not tile then return x,y end
		if tile:isOpaque() then
			return x, y
		end
		lastx, lasty = x, y
	end
    return x1, y1
end

-- This should walk along a wall marking it visible, until it hits a corner, another visible tile,
-- the edge of the screen/world, or if the wall is blocked visually
-- direction chooses to go right or left (1 or -1)
local function lightTraceWall( x, y, z, nx, ny, direction, xMin, xMax, yMin, yMax )
    if not ply then return end
	if nx == 0 and ny == 0 then return end
	if nx ~= 0 and ny ~= 0 then return end
	local x0,y0 = x,y
    local nx0,ny0 = nx*direction, ny*direction
	-- the normal tells us which way to travel, as does the direction
	x0 = x0 + ny0
	y0 = y0 + nx0
	local tile = level:getTurf( x0, y0, z )
	while tile and tile:isOpaque() do
		if not (x0 >= xMin and x0 <= xMax and y0 >=  yMin and y0 <= yMax) then
			break
		end
		-- checking corners
		local test = level:getTurf( x0+nx, y0+ny, z )
		-- ENEMY SPOTTED
		if test and test:isOpaque() then
            local dx = ply.x-x0
            local dy = ply.y-y0
            dx = dx/abs(dx)
            dy = dy/abs(dy)
            -- shoot gun
            local tx, ty = rayTrace( x0+dx, y0+dy, z, ply.x, ply.y )
            -- BOOM HEADSHOT
            if tx == ply.x and ty == ply.y then
                tile.visible = true
            end
			break
        end
        -- checking visibility
        -- we push it out a little with the normal to not get blocked by the wall itself
        local tx, ty = rayTrace( x0+nx, y0+ny, z, ply.x, ply.y )
        if tx == ply.x and ty == ply.y then
            tile.visible = true
        end
		-- moving on...
		x0 = x0 + ny0
		y0 = y0 + nx0
		tile = level:getTurf( x0, y0, z )
	end
end

local function lightTraceToBorder( x, y, z, xMin, xMax, yMin, yMax )
	for bx = xMin, xMax do
		local px,py,nx,ny = lightTrace( x, y, z, bx, yMin )
		local dx,dy,ux,uy = lightTrace( x, y, z, bx, yMax )
        lightTraceWall( px, py, z, nx, ny, 1, xMin, xMax, yMin, yMax )
        lightTraceWall( px, py, z, nx, ny, -1, xMin, xMax, yMin, yMax )
        lightTraceWall( dx, dy, z, ux, uy, 1, xMin, xMax, yMin, yMax )
        lightTraceWall( dx, dy, z, ux, uy, -1, xMin, xMax, yMin, yMax )
	end
	for by = yMin, yMax do
		local px,py,nx,ny = lightTrace( x, y, z, xMin, by )
		local dx,dy,ux,uy = lightTrace( x, y, z, xMax, by )
        lightTraceWall( px, py, z, nx, ny, 1, xMin, xMax, yMin, yMax )
        lightTraceWall( px, py, z, nx, ny, -1, xMin, xMax, yMin, yMax )
        lightTraceWall( dx, dy, z, ux, uy, 1, xMin, xMax, yMin, yMax )
        lightTraceWall( dx, dy, z, ux, uy, -1, xMin, xMax, yMin, yMax )
	end
end

local function debugTraceToBorder( x, y, z, xMin, xMax, yMin, yMax, xoff, yoff, sx, sy )
	for bx = xMin, xMax+1 do
		debugTrace( x, y, z, bx, yMin, xoff, yoff, sx, sy )
		debugTrace( x, y, z, bx, yMax, xoff, yoff, sx, sy )
	end
	for by = yMin, yMax+1 do
		debugTrace( x, y, z, xMin, by, xoff, yoff, sx, sy )
		debugTrace( x, y, z, xMax, by, xoff, yoff, sx, sy )
	end
end

local function clearVisibility( z, xMin, xMax, yMin, yMax )
	for x = xMin, xMax do
		for y = yMin, yMax do
            local turf = level:getTurf( x, y, z )
            if turf then turf.visible = nil end
		end
	end
end

local fov = {}
fov.debugTraceToBorder = debugTraceToBorder
fov.lightTraceToBorder = lightTraceToBorder
fov.clearVisibility = clearVisibility
return fov
