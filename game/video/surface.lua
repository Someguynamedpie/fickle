local ffi = require'ffi'

local M = {
	scaleX = 1,
	scaleY = 1,
	drawR = 255,
	drawG = 255,
	drawB = 255,
	drawA = 255,
	alphaMultiplier = 1,
}
local r
function M.init( renderer )
	M.r = renderer
	r = M.r
	sdl.SetRenderDrawBlendMode( M.r, sdl.BLENDMODE_BLEND )
	return M
end
function M.setScale( sX, sY )
	M.scaleX = sX or 1
	M.scaleY = sY or 1
end
function M.scale( sX, sY )
	M.scaleX = M.scaleX * (sX or 1)
	M.scaleY = M.scaleY * (sY or 1)
end
function M.getScale()
	return M.scaleX or 0, M.scaleY or 0
end
function M.setAlphaMultiplier( n )
	M.alphaMultiplier = n
end
function M.setAlphaMultiplierOverride( n )
	M.alphaMultiplierO = n
end
function M.getAlphaMultiplier()
	return M.alphaMultiplierO or M.alphaMultiplier
end
function M.setDrawColor( color, g, b, a )
	if g then
		M.drawR = color
		M.drawG = g
		M.drawB = b
		M.drawA = a or 255
		sdl.SetRenderDrawColor( r, color, g, b, (a or 255) * M.getAlphaMultiplier() )
	else
		M.drawR = color.r
		M.drawG = color.g
		M.drawB = color.b
		M.drawA = color.a
		sdl.SetRenderDrawColor( r, color.r, color.g, color.b, color.a * M.getAlphaMultiplier() )
	end
end

local mrect = ffi.new( 'SDL_Rect' )

local tX, tY = 0, 0
function M.translate( x, y )
	tX = x * M.scaleX + tX
	tY = y * M.scaleY + tY
end

function M.setTranslation( x, y )
	tX = x * M.scaleX
	tY = y * M.scaleY
end

local function rect( x, y, w, h, dest )
	local xlate = false
	if not dest then xlate = true end
	dest = dest or mrect
	if xlate then
		dest.x = x * M.scaleX + tX
		dest.y = y * M.scaleY + tY
		dest.w = w * M.scaleX
		dest.h = h * M.scaleY
	else
		dest.x = x
		dest.y = y
		dest.w = w
		dest.h = h
	end
	return dest
end
M.getRect = rect


function M.drawRect( x, y, w, h )
	sdl.RenderDrawRect( r, rect( x, y, w, h ) )
end

function M.fillRect( x, y, w, h )
	sdl.RenderFillRect( r, rect( x, y, w, h ) )
end

function M.drawLine( x, y, x2, y2 )
	sdl.RenderDrawLine( r, x * M.scaleX + tX, y * M.scaleY + tY, x2 * M.scaleY + tX, y2 * M.scaleY + tY )
end

function M.drawDot( x, y )
	sdl.RenderDrawPoint( r, x * M.scaleX + tX, y * M.scaleY + tY )
end

function M.setTexture( tex )
	if not tex or not tex.tex then return end
	if not tex.blendSet then tex.blendSet = true sdl.SetTextureBlendMode( tex.tex, sdl.BLENDMODE_BLEND ) end
	sdl.SetTextureAlphaMod( tex.tex, M.getAlphaMultiplier() * 255 )
	M.texture = tex.tex
end

function M.setTextureColor( color, g, b, a )
	if g then sdl.SetTextureColorMod( M.texture, color, g, b ) if a then sdl.SetTextureAlphaMod( M.texture, a * M.getAlphaMultiplier() ) end else
		sdl.SetTextureColorMod( M.texture, color.r, color.g, color.b )
		if color.a ~= 255 or M.getAlphaMultiplier() ~= 1 then
			sdl.SetTextureAlphaMod( M.texture, color.a * M.getAlphaMultiplier() )
		end
	end
end

function M.drawTexturedRect( x, y, w, h )
	if M.texture then
		sdl.RenderCopy( r, M.texture, nil, rect( x, y, w, h ) )
	else
		M.setDrawColor( 255, 0, 255 )
		M.fillRect( x, y, w, h )
		M.setDrawColor( 0, 0, 0 )
		M.fillRect( x + w/2, y, w/2, h/2 )
		M.fillRect( x, y + h/2, w/2, h/2 )
	end
end


local subrect = ffi.new( 'SDL_Rect' )
local point   = ffi.new( 'SDL_Point' )
FLIP_X = sdl.FLIP_HORIZONTAL
FLIP_Y = sdl.FLIP_VERTICAL

function M.drawTexturedSubrect( x, y, w, h, ix, iy, iw, ih, ang, flip, originX, originY )
	if M.texture then
		originX = originX or w/2
		if originX then
			point.x = originX
			point.y = originY or h/2
		end
		
		sdl.RenderCopyEx( r, M.texture, rect( ix, iy, iw, ih, subrect ), rect( x, y, w, h ), ang or 0, point, flip or 0 )
	else
		M.setDrawColor( 255, 0, 255 )
		M.fillRect( x, y, w, h )
		M.setDrawColor( 0, 0, 0 )
		M.fillRect( x + w/2, y, w/2, h/2 )
		M.fillRect( x, y + h/2, w/2, h/2 )
	end
end

function M.setFont( font )
	M.primaryFont = M.primaryFont or font
	M.font = font or M.primaryFont
end
function M.drawCircle( x, y, radius )
	M.drawOval( x, y, radius, radius )
end
function M.fillCircle( x, y, radius )
	M.fillOval( x, y, radius, radius )
end
function M.drawOval( x, y, w, h )
	gfx.ellipseRGBA( r, x * M.scaleX + tX, y * M.scaleY + tY, w * M.scaleX, h * M.scaleY, M.drawR, M.drawG, M.drawB, M.drawA * M.getAlphaMultiplier() )
end
function M.fillOval( x, y, w, h )
	gfx.filledEllipseRGBA( r, x * M.scaleX + tX, y * M.scaleY + tY, w * M.scaleX, h * M.scaleY, M.drawR, M.drawG, M.drawB, M.drawA * M.getAlphaMultiplier() )
end

function M.setTextColor( r, g, b, a )
	if r and not g then
		M.fontR = r.r
		M.fontG = r.g
		M.fontB = r.b
		M.fontA = r.a
	else
		M.fontR = r
		M.fontG = g or 255
		M.fontB = b or 255
		M.fontA = a
	end
end
function M.drawText( str, x, y )
	M.font:draw( str, x, y )
end
function M.setClipRect( x, y, w, h )
	if not x then
		sdl.RenderSetClipRect( r, nil )
	else
		sdl.RenderSetClipRect( r, rect( x, y, w, h ) )
	end
end

function M.getFont() return M.font end
function M.getTextSize( txt )
	return M.font:getTextSize( txt )
end

return M
