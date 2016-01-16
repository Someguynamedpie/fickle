local richformat,b = require('gui.richformat')
local panel = class( 'gui.RichText', 'gui.Panel' )

function panel:init()
    self.text = richformat.New(256, 256, 500)
    self:setBackgroundColor(color_darkgray)
end
function panel:draw()
    self.baseclass.draw(self)
    self.text:Draw()
end
function panel:onmousedown( btn, x, y )
	if( btn == MOUSE_LEFT ) then
		self.text:SetSelectionStart( {x = x, y = y} )
		self.selectedBlock = self.text:GetStyleForPosition({x = x, y = y}, true)
		self.text:CalcDraw()
	end
end
function panel:onmouseup( btn, x, y )
	if( btn == 'wu' ) then
		self.text:SetScroll( math.clamp( self.text:GetScroll( ) - 20, 0, self.text:GetTotalHeight( ) - self.h ) )
	elseif( btn == 'wd' ) then
		self.text:SetScroll( math.clamp( self.text:GetScroll( ) + 20, 0, self.text:GetTotalHeight( ) - self.h ) )
	elseif not self.dragging and btn == MOUSE_LEFT then
		self.text:DoClick( { x = x, y = y } )
	end
end
function panel:onscroll( x, y )
    self.text:SetScroll( math.clamp( self.text:GetScroll( ) - y * 20, 0, self.text:GetTotalHeight( ) - self.h ) )
end
function panel:onmousemove( x, y )
	self:setCursor(self.text:GetCursor( {x=x,y=y} ))
    if self.depressed then
        self.text:SetSelectionEnd( {x=x, y=y } )
    end
end

function panel:addText( ... )
	local isAtBottom = self.text:GetTotalHeight( ) <= self.h or self.text:GetScroll( ) >= self.text:GetTotalHeight( ) - self.h
	local curcol = color_white
	local curfont = self.text.font
	for k,v in pairs( {...} ) do
		local t = type( v )
		if( t == "table" and v.r and v.g and v.b and v.a ) then
			curcol = v
		elseif( type( t ) == "userdata" and v.getLineHeight ) then
			curfont = v
			self.text.font = v
		else

			self.text:Add( tostring( v ), curcol, curfont )
		end
	end
	if( isAtBottom and self.text:GetTotalHeight( ) > self.h ) then
		self.text:SetScroll( self.text:GetTotalHeight( ) - self.h )
	end
end

function panel:onlayout( )
	self.text:SetSize( self.w, self.h )
	local isAtBottom = self.text:GetTotalHeight( ) <= self.h or self.text:GetScroll( ) >= self.text:GetTotalHeight( ) - self.h
	if( isAtBottom ) then
		self.text:SetScroll( self.text:GetTotalHeight( ) - self.h )
	end
end

return panel
