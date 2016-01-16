local M = {}
local dirs = {
	's', 'n', 'e', 'w', 'se', 'sw', 'ne', 'nw'
}
local divisor = 10
function M.load( tex,log )
	if not tex.dmi then error( "Texture doesn't have DMI data!" ) end
	local dmi = tex.dmi
	for k, v in pairs( dmi ) do
		if v.key == 'version' then
			for k,v in pairs(v.keys) do print(k,v) end
			tex.dmwidth = v.keys.width
			tex.dmheight = v.keys.height
			break
		end
	end
	local states = {}
	local x, y = 0, 0
	for k,v in pairs(dmi) do
		local frames = {}
		if v.key ~= 'version' then
			if log then print(v.value) end

			for n = 1, tonumber(v.keys.frames) do

				for d = 1, tonumber( v.keys.dirs or 1 ) do
					frames[ dirs[ d ] ] = frames[ dirs[ d ] ] or {}
					table.insert( frames[ dirs[ d ] ], {x, y} )
					x = x + tex.dmwidth
					if( x >= tex.width ) then
						x = 0
						y = y + tex.dmheight

					end
				end

			end
		end
		--print(v.keys.delay)
		local del = v.keys.delay and v.keys.delay:split','

		local n = 0
		if del then for k, v in pairs( del ) do n = n + tonumber( v ) del[k] = tonumber(del[k])/divisor end del.total = n/divisor end
		states[ v.value ] = {frames = frames, delays = del}

	end
	tex.states = states
end
local system=require'system'
function M.render( tex, state, x, y, dir, w, h, frame, col, rot )
	local frames = tex.states[ state ]
	if not frames then
		return
	end
	local delays = frames.delays
	local playframe = 1
	if delays then
		local modulo = delays.total
		local secs
		if frame then
			secs = (system.getTime() - frame)%modulo
		else
			secs = ( system.getTime() + ( randomizer or 0 )) % modulo--lol sex
		end
		local total = delays[ 1 ]
		for i = 1, #delays do--todo inefficient?
			if secs > total then
				total = total + delays[i]
			else
				playframe = i
				break
			end
		end
	end

	frames = frames.frames
	local frame = frames[dir or 's'] or frames['s']
	--if not frame then print("INVALID DIRECTION FOR STATE " .. tostring(state) .. ": " .. dir) return end
	frame = frame[playframe]
	if not frame then print("INVALID FRAME FOR STATE " .. tostring(state) .. ": " .. (math.floor((system.getTime()*4 + (randomizer or 0)) % #frame + 1))) return end
	surface.setTexture( tex )
	if col then surface.setTextureColor(col) end
	--surface.drawTexturedRect( x, y, tex.width, tex.height )

	surface.drawTexturedSubrect( x, y, w or tex.dmwidth, h or tex.dmheight, frame[1], frame[2], tex.dmwidth, tex.dmheight, rot or 0 )
end

return M
