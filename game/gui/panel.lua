local gui = ...
local panel = class( 'gui.Panel' )
DOCK_NONE = 0
DOCK_TOP = 1
DOCK_LEFT = 2
DOCK_BOTTOM = 4
DOCK_RIGHT = 8
DOCK_FILL = 16
function panel:init(...) end
panel.minW = 8
panel.minH = 8
function panel:initialize(...)
	self.x = 0
	self.y = 0
	self.z = 0
	self.w = 32
	self.h = 32
	self.passthru = false
	self.opacity = 1
	self.children = {}
	self.visible = true
	self.docked = DOCK_NONE
	self.dirty = false

	self.scaleX = 1
	self.scaleY = 1

	self.dockedMargins = {left = 4, top = 4, right = 4, bottom = 4}
	self.dockedPadding = {left = 4, top = 4, right = 4, bottom = 4}

	self.navTargets = {}
	if gui.root then self:setParent( gui.root ) end

	self:init( ... )
end
function panel:dock( n )
	self.docked = n
	self.parent:invalidateLayout()
end
function panel:invalidateLayout()
	self.dirty = true
end
function panel:runLayout()
	self:validateLayout()
	for k,v in pairs( self.children ) do
		v:validateLayout()
	end
end
function panel:getBounds()
	return {x=self.x, y=self.y, w=self.w, h=self.h}
end
function panel:getMargins()
	return self.dockedMargins
end
function panel:setMargins(left, right, top, bottom)
	self.dockedMargins = {left = left, top = top, right = right, bottom = bottom}
end
function panel:getPadding()
	return self.dockedPadding
end
function panel:setPadding(left, right, top, bottom)
	self.dockedPadding = {left = left, top = top, right = right, bottom = bottom}
end
function panel:setBounds(x,y,w,h)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
end
local band = bit.band
function panel:validateLayout()
	if self.docked then
		local padding = self:getPadding( )
		local x, y, dx, dy = 0, 0, 0, 0
		local w, h, dw, dy = 0, 0, 0, 0

		x = 0
		w = self:getWidth()
		y = 0
		h = self:getHeight()

		for k, v in ipairs( self.children ) do
			local dock = v.docked
			local margin = v:getMargins( )
			if( dock ~= DOCK_NONE and v.visible ) then
				dx = x + padding.left
				dw = w - ( padding.left + padding.right )
				dy = y + padding.top
				dh = h - ( padding.top + padding.bottom )
			end
			if( dock ~= DOCK_FILL or not v.visible ) then

				if( band( dock, DOCK_TOP ) > 0 ) then
					local height = margin.top + margin.bottom + v.h
					v:setBounds( dx + margin.left, dy + margin.top, dw - margin.left - margin.right, v.h )
					y = y + height
					h = h - height
				end
				if( band( dock, DOCK_LEFT ) > 0 ) then
					local width = margin.left + margin.right + v.w
					v:setBounds( dx + margin.left, dy + margin.top, v.w, dh - margin.top - margin.bottom )
					x = x + width
					w = w - width
				end
				if( band( dock, DOCK_RIGHT ) > 0 ) then
					local width = margin.left + margin.right + v.w
					v:setBounds( ( dx + dw) - v.w - margin.right, dy + margin.top, v.w, dh - margin.top - margin.bottom )
					w = w - width
				end
				if( band( dock, DOCK_BOTTOM ) > 0 ) then
					h = h - ( v.h + margin.bottom + margin.top )
					v:setBounds( dx + margin.left, ( dy + dh ) - v.h - margin.bottom, dw - margin.left - margin.right, v.h )
				end

			end
		end

		for k,v in ipairs( self.children ) do
			local dock = v.docked

			if( band( dock, DOCK_FILL ) > 0 ) then
				dx = x + padding.left
				dw = w - ( padding.left + padding.right )
				dy = y + padding.top
				dh = h - ( padding.top + padding.bottom )
				local margin = v:getMargins( )
				v:setBounds( dx + margin.left, dy + margin.top, dw - margin.left - margin.right, dh - margin.top - margin.bottom )
			end

		end
	end
	self:onlayout()
end
function panel:setPos( x, y )
	self.x = x or 0
	self.y = y or 0
end
NAV_UP = 1
NAV_DOWN = 2
NAV_LEFT = 3
NAV_RIGHT = 4

function panel:navigate( dir )
	if( self.navTargets[ dir ] ) then
		gui.setFocus( self.navTargets[ dir ], true )
		
	end
end
local opposites = {
	[NAV_UP] = NAV_DOWN,
	[NAV_DOWN] = NAV_UP,
	[NAV_LEFT] = NAV_RIGHT,
	[NAV_RIGHT] = NAV_LEFT,
}
function panel:setNavTarget( dir, pan, noRecurse )
	self.navTargets[ dir ] = pan
	if not noRecurse then
		pan:setNavTarget( opposites[ dir ], self, true )
	end
end

function panel:setSize( w, h )
	self.w = math.max( w or 0, self.minW )
	self.h = math.max( h or 0, self.minH )
	self:invalidateLayout()
end
function panel:setMinimumSize( w, h )
	self.minW = w self.minH = h
	self:setSize( self:getSize() )
end
function panel:setParent( newParent )
	if self.parent then
		self.parent:removeChild( self )
	end
	self.parent = newParent or gui.root
	self.parent:addChild( self )
end
function panel:remove() self:onremove() self.parent:removeChild( self ) end
function panel:clear()
	local con--hackhackhack
	for k, v in pairs( self.children ) do
		if not v.CONSOLE then
			v:onremove()
			v:clear()
		else con = v print'cansal' end
	end
	self.children = {con}
end
function panel:setVisible( visible )
	self.visible = visible
end
function panel:isVisible()return self.visible and (self.parent and self.parent:isVisible() or true) end
function panel:removeChild( child )
	for k,v in pairs( self.children ) do
		if( v == child ) then
			table.remove( self.children, k )
			break
		end
	end
end
local function zSort( a, b )
	return a.z > b.z
end
function panel:bringToFront()
	if not self.parent then return end
	local idx = #self.parent.children
	if not self.poppedOver then
		for i = #self.parent.children, 1, -1 do
			if self.parent.children[i].poppedOver then
				idx = i - 1
			else
				break
			end
		end
	end
	for i, v in ipairs( self.parent.children ) do
		if( v == self ) then table.remove( self.parent.children, i ) break end

	end


	table.insert( self.parent.children, idx , self )
	self.parent:bringToFront()
end
function panel:setPoppedOver(po)
	self.poppedOver = po
	if po then self:bringToFront() end
end
function panel:makePopup()
	self:setPoppedOver(true)
end
function panel:addChild( child )
	table.insert( self.children, child )
	--child:bringToFront()
end
function panel:getOpacity()return self.opacity * (self.parent and self.parent:getOpacity() or 1) end
function panel:render()
	if not self.visible then return end

	if self.dirty then
		self.dirty = false
		self:runLayout()
	end

	surface.setAlphaMultiplierOverride(self:getOpacity())
	surface.translate( self.x, self.y )
	local oSX, oSY = surface.getScale()
	surface.scale( self.scaleX, self.scaleY )
	self:draw()
	for i, v in ipairs( self.children ) do
		if v.x < self.w and v.y < self.h and v.x + v.w > 0 and v.y + v.h > 0 then
			v:clip()
			v:render()
		end
	end
	surface.setAlphaMultiplierOverride()
	surface.translate( -self.x, -self.y )
	surface.setScale( oSX, oSY )
end
function panel:draw9patch( x, y, w, h, imX, imY, imW, imH, patchSize )
	surface.drawTexturedSubrect( x, y, patchSize, patchSize, imX, imY, patchSize, patchSize )--topleft
	surface.drawTexturedSubrect( x + w - patchSize, y, patchSize, patchSize, imX + imW - patchSize, imY, patchSize, patchSize )--topright
	surface.drawTexturedSubrect( x + patchSize, y, imW - patchSize, patchSize, imX + patchSize, imY, patchSize, patchSize )--top



	surface.drawTexturedSubrect( x, y + h - patchSize, w, patchSize, imX, imY + imH - patchSize, imW, patchSize )
	surface.drawTexturedSubrect( x + w - patchSize, y, patchSize, h, imX + imW - patchSize, imY, patchSize, imH)
end

local scheme = require( 'gui.scheme' )
panel.backgroundColor = scheme.panel.background
function panel:setBackgroundColor( color )
	self.backgroundColor = color or scheme.panel.background
end
function panel:draw()
	surface.setDrawColor( self.backgroundColor )
	surface.fillRect( 0, 0, self.w, self.h )

	surface.setDrawColor( scheme.panel.border )
	surface.drawRect( 0, 0, self.w, self.h )

	surface.setDrawColor( scheme.panel.borderBright )
	surface.drawRect( 0, self.h - 1, self.w, 2 )
	surface.drawRect( self.w - 1, 0, 2, self.h )
end
function panel:getWorldPos()
	local x, y = 0, 0
	local curChild = self
	while curChild do
		x = x + curChild.x * curChild.scaleX
		y = y + curChild.y * curChild.scaleY
		curChild = curChild.parent
	end
	return x, y
end
function panel:worldToLocal( x, y )
	local wX, wY = self:getWorldPos()
	return x - wX, y - wY
end
function panel:localToWorld( x, y )
	local wX, wY = self:getWorldPos()
	return x + wX, y + wY
end
function panel:getScale()
	local scX, scY = self.scaleX, self.scaleY
	if self.parent then
		local pX, pY = self.parent:getScale()
		scX = scX * pX
		scY = scY * pY
	end
	return scX, scY
end

function panel:clip()
	--if not self.parent or true then return end-- if self.parent.parent then return end
	local x, y, w, h = self.x, self.y, self.w, self.h
	local pw, ph = self.parent.w, self.parent.h

	x = math.max( x, 0 )
	y = math.max( y, 0 )
	if( x + w > pw ) then
		w = pw - x
	end
	if( y + h > ph ) then
		h = ph - y
	end

	surface.setClipRect( x, y, math.max( w, 0 ), math.max( h, 0 ) )
end

function panel:isPointOverWorld( x, y )
	if not self.visible then return end
	local scX, scY = self:getScale()

	local sX, sY = self:getWorldPos()

	return x>sX and y>sY and x<sX+(self.w * scX) and y<sY+(self.h * scY)
end
function panel:setCursor( cursor )
	self.cursor = cursor
end
function panel:getPanelOverPoint( x, y )
	if not self:isPointOverWorld( x, y ) then return end
	for i = #self.children, 1, -1 do
		local v = self.children[ i ]
		if not v.passthru and v:isPointOverWorld( x, y ) then
			return v:getPanelOverPoint( x, y, true )
		end
	end
	return self
end
local tween = require( 'lib.tween' )
function panel:fadeIn( cb, duration, mode ) tween.remove(self.fadeTween)
	self:setVisible( true )
	if not(self.fadingIn or self.fadingOut) then
		self.opacity = 0
		self.scaleX = 1.25
		self.scaleY = 1.25
		self.dx = self.dx or self.x
		self.dy = self.dy or self.y
		self.x = self.dx - (1/self.scaleX) * 64
		self.y = self.dy - (1/self.scaleY) * 64
	end
	self.fadingOut = false
	self.fadingIn = true
	self.fadeTween = tween.new( self, {
		x = self.dx,
		y = self.dy,
		scaleX = 1,
		scaleY = 1,
		opacity = 1
	}, duration or .3, mode or 'inSine', function()
		self.fadeTween = nil
		self.x = self.dx
		self.y = self.dy

		self.dx = nil
		self.dy = nil
		self.fadingIn = false
	if cb then cb() end end )

end

function panel:fadeOut( cb, duration, mode ) tween.remove(self.fadeTween)
	self:setVisible( true )
	if not(self.fadingIn or self.fadingOut) then
		self.opacity = 1
		self.dx = self.dx or (self.x)
		self.dy = self.dy or (self.y)
	end
	self.fadingIn = false
	self.fadingOut = true
	self.fadeTween = tween.new( self, {
		x = self.dx - (1/1.25) * 64,
		y = self.dy - (1/1.25) * 64,
		scaleX = 1.25,
		scaleY = 1.25,
		opacity = 0

	}, duration or .3, mode or 'outSine', function(self)
		self.fadingOut = false
		self:setVisible( false )
		self.x = self.dx
		self.y = self.dy
		self.dx = nil
		self.dy = nil
		self.scaleX = 1
		self.scaleY = 1
		if cb then cb() end
	end)
end

function panel:setScale( sX, sY )
	self.scaleX = sX or 1
	self.scaleY = sY or 1
end

function panel:getSize()
	return self:getWidth(), self:getHeight()
end
function panel:getWidth() return self.w end
function panel:getHeight() return self.h end
function panel:setWidth(w) return self:setSize( w, self:getHeight() ) end
function panel:setHeight(h) return self:setSize( self:getWidth(), h ) end
function panel:center()
	self:setPos( self.parent:getWidth() / 2 - self:getWidth() / 2, self.parent:getHeight() / 2 - self:getHeight() / 2 )
end

function panel:onfocus(gained) end
function panel:onmousedown(btn, x, y, clicks) end
function panel:onmouseup(btn, x, y, clicks) end
function panel:onmousemove(x, y, rx, ry) end
function panel:ontextinput(txt) end
function panel:onime(txt,start,len) end
function panel:onkeypress(btn, modifiers, rep) end
function panel:onkeyrelease(btn, modifiers, rep) end
function panel:onlayout() end
function panel:onscroll(x,y) end
function panel:onremove() end
return panel
