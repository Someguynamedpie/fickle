local M = {}

function M.enum( x0, y0, x1, y1 )
    local x, y = x0, y0
	local sx,sy,dx,dy

	if x < x1 then
		sx = 1
		dx = x1 - x
	else
		sx = -1
		dx = x - x1
	end

	if y < y1 then
		sy = 1
		dy = y1 - y
	else
		sy = -1
		dy = y - y1
	end

	local err, e2 = dx-dy, nil

	e2 = err + err
	if e2 > -dy then
		err = err + dy
		x	= x - sx
	end
	if e2 < dx then
		err = err - dx
		y	= y - sy
	end

	return function()
		while not(x == x1 and y == y1) do
			e2 = err + err
			if e2 > -dy then
				err = err - dy
				x	= x + sx
			end
			if e2 < dx then
				err = err + dx
				y	= y + sy
			end
			return x,y
		end
	end
end

return M
