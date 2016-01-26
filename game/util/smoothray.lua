local M = {}
local round = math.round
local sin = math.sin
local cos = math.cos

function M.enum( x0, y0, x1, y1, step )
    local ang = math.atan2( y0-y1, x0-x1 )+math.pi
    local s = step or 0.2
    local x, y = x0, y0
    local xmem = round(x)
    local ymem = round(y)
    while( xmem == round(x) and ymem == round(y) ) do
        x = x - cos(ang)*s
        y = y - sin(ang)*s
    end
    xmem = round(x)
    ymem = round(y)
	return function()
		while not(xmem == x1 and ymem == y1) do
            while( xmem == round(x) and ymem == round(y) ) do
                x = x + cos(ang)*s
                y = y + sin(ang)*s
            end
            xmem = round(x)
            ymem = round(y)
			return xmem, ymem
		end
	end
end

return M
