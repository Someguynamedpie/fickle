local panel = class( 'gui.Textbox', 'gui.Panel' )

--todo: only render whats visible

local system = require( 'system' )
local scheme = require( 'gui.scheme' )
function panel:init()
	self.text = ''
	self.font = surface.getFont()
	self.color = scheme.textbox.color
	self.multiline = false
	self.mask = nil
	self.lineBreaks = {{start=0,last=0}}

	self.selection = {
		0, -1
	}

	--self.renderOffset = {0, 0}
	self.placeholder = nil
	self.placeholderAlpha = 0
	self.placeholderAnim = nil
	self.placeholderShow = false
	self.ime = ''
	self.cursor = 'ibeam'
	self.badMatchAnim = nil
	self.badMatchColor= nil
	self.scrollCaret = 0
end
function panel:getText()
	return self.text
end
function panel:setText(txt)
	self.text = txt
	self:calculateLineBreaks()
end
function panel:setPlaceholder( txt )
	self.placeholder = txt
end
function panel:setMask( ch )
	self.mask = ch
end
function panel:getMask( ch )
	return self.mask
end
function panel:setMultiline( ml )
	self.multiline = ml
end
function panel:getColor()
	return self.color
end
function panel:setColor( newColor )
	self.color = newColor
end

function panel:length(str)
	return (str or self.text):utf8len()
end
function panel:charAt( i, str )
	return (str or self.text):utf8sub( i, i )
end
function panel:substr( idxStart, idxEnd, str )
	return (str or self.text):utf8sub( idxStart, idxEnd )
end

function panel:calculateLineBreaks()
	for i = 1, self:length() do
		local ch = self:charAt( i )
		if ch == '\n' then
			table.insert( self.lineBreaks, i )
		end
	end
end

function panel:getYStart()
	return self.multiline and 1 or (self:getHeight()/2 - self.font:getHeight()/2)
end
local function order( a, b, rev )
	if rev then
		if b < a then return b, a end
	else
		if b > a then return b, a end
	end
	return a, b
end
panel.exsetBackgroundColor = panel.setBackgroundColor
function panel:setBackgroundColor( col, override )
	if not override then
		self.bg = col
	end
	self.exsetBackgroundColor(self, col)
end
function panel:draw()
	if self.badMatchColor then
		self:exsetBackgroundColor( (self.bg or scheme.panel.background):fadeTo( scheme.textbox.badMatchColor, self.badMatchColor ) )
	end
	self.baseclass.draw( self )
	surface.setFont( self.font )

	local textColor = self:getColor()
	local width, height = self:getSize()

	local X, Y = 2, self:getYStart()
	local w, h, fontOptimize

	surface.setDrawColor( 60, 60, 200, 128 )

	local selStart, selW

	local curLineBreak = 1
	
	local rOffX, rOffY = self:getRenderOffset()
	
	rOffY = rOffY - self.font:getHeight()/2
	
	surface.translate( rOffX, rOffY )

	local str = #self.ime ~= 0 and (self:substr( 0, self:getCaret() ) .. (self.ime) .. self:substr( self:getCaret() + 1 )) or self.text
	local x, y = self:getCaretXY()

	for i = 1, self:length(str) do
		local ch = self:charAt( i, str )

		if self.multiline and (self.lineBreaks[ curLineBreak ].last - (#self.ime ~= 0 and (self:length(self.ime) - 1) or 0)) == i - 1 then
			if selStart then
				surface.fillRect( selStart, Y, selW, self.font:getHeight() )
				selStart = nil
			end
			X = 2
			Y = Y + self.font:getHeight()
			curLineBreak = curLineBreak + 1
		else
			ch = self:getMask() or ch
			w, h, fontOptimize = self.font:drawChar( ch, X, Y, fontOptimize )

			if self:hasSelection() then
				if ( i > self:getCaret( true ) and i <= self:getCaret() ) or ( i > self:getCaret() and i <= self:getCaret( true ) ) then
					if not selStart then
						selStart = X
						selW = w
					else
						selW = selW + w
					end
				end
			end
			X = X + w
		end
	end
	if selStart then
		surface.fillRect( selStart, Y, selW, self.font:getHeight() )
	end


	if self.focussed then self:drawCaret() end

	if self.doDeselect then self.doDeselect = false self:deselect() end

	if self.placeholder then--todo cleanup
		if #self.text > 0 and self.placeholderShow then
			if self.placeholderAnim then tween.remove( self.placeholderAnim ) end
			self.placeholderAnim = tween.eztween( .5, 'outCubic', nil, true )
			self.placeholderShow = false
		elseif #self.text == 0 and self.placeholderShow == false then
			if self.placeholderAnim then tween.remove( self.placeholderAnim ) end
			self.placeholderShow = true
			self.placeholderAnim = tween.eztween( .5, 'outCubic', nil, false )
		end
		local old = surface.alphaMultiplierO
		surface.setAlphaMultiplierOverride( self.placeholderAnim() * self:getOpacity() )

		local oX, oY = 2, self:getYStart()
		surface.drawText( self.placeholder, oX, oY )
		surface.setAlphaMultiplierOverride( old )
	end
	surface.translate( -rOffX, -rOffY )
end

function panel:drawCaret()
	local x, y = self:caretToPixel( self:getCaret() )
	local col = scheme.textbox.caretColor
	surface.setDrawColor( col.r, col.g, col.b, math.sin(system.getTime()*10)*128+128)
	surface.drawRect( x, y, 2, self.font:getHeight() )
end
function panel:getCaret( sel )
	return self.selection[ sel and 2 or 1]
end
function panel:caretToPixel( idx )
	local w, h = self.font:getTextSize( (self:getMask() and self:getMask():rep( idx ) or self:substr( 1, idx ) ) )
	return w, h + self:getYStart() - self.font:getHeight()
end

function panel:onfocus( focussed, navigated )
	if focussed then
		local wX, wY = self:getWorldPos()
		input.startTextInput( wX, wY, self:getWidth(), self:getHeight() )
		if navigated then self:setCaret( self:length() ) end
	else
		input.finishTextInput()
		self:setCaret( -1, true )
	end
end
function panel:delete( offset )
	if self:hasSelection() then self:deleteSelection() return end
	local start, finish = self:getCaret(), self:getCaret() + offset
	self:replace( start, finish, '' )
	if( offset < 0 ) then
		self:setCaret( self:getCaret() + offset )
		self:scrollLeft()
	end
	
end
function panel:replace( start, finish, with )
	local dir = start >= finish
	start, finish = order( start, finish, true  )
	self.text = self:substr( 1, start ) .. with .. self:substr( finish + 1 )

	self:recalculateNewlines()
end
function panel:hasSelection()
	return self:getCaret( true ) >= 0
end

function panel:deleteSelection()
	if self:hasSelection() then
		self:replace( self.selection[1], self.selection[2], '' )
		if self.selection[1] > self.selection[2] then
			self:setCaret( self.selection[ 2 ] )
		end
		self:deselect()
		self:scrollLeft()
	end
end

function panel:insert( txt, at )
	self:deleteSelection()
	at = at or self:getCaret()
	self.text = self:substr( 1, at ) .. txt .. self:substr( at + 1 )
	if self.upper then self.text = self.text:upper() end
	self:setCaret( self:getCaret() + self:length(txt) )
	self:recalculateNewlines()
	self:scrollRight()
end

function panel:recalculateNewlines()
	if not self.multiline then
		self.lineBreaks[1].last = #self.text
		return
	end--fart
	self.lineBreaks = {}
	local found = false
	local last = 0
	for i = 1, self:length() do
		if( self:charAt( i ) == '\n' ) then
			table.insert( self.lineBreaks, {start = last, last = i - 1} )
			last = i
		end
	end
	table.insert( self.lineBreaks, {start = last, last = #self.text} )
end

function panel:moveCursor( x, y )--move to x characters across, y lines down
	local idx = math.max( math.min( y or 1, #self.lineBreaks), 1 )
	local line = self.lineBreaks[ idx ]
	self:setCaret( line.start + math.max( math.min( x, self:length( self:substr( line.start, line.last ) ) ), 0 ) )
end

function panel:getCaretXY( caret )
	caret = caret or self:getCaret()
	for i = 1, #self.lineBreaks do
		local line = self.lineBreaks[ i ]
		if( caret <= line.last and caret >= line.start ) then
			return caret - line.start, i
		end
	end
end

function panel:deselect()
	self.selection[2] = -1
end


function panel:scrollRight()
	if self.multiline then return end
	if( #self.text == 0 ) then self.scrollCaret = 0 return end
	local x, y = self:caretToPixel( self:getCaret() )
	local x2, y2 = self:caretToPixel( self.scrollCaret )
	while (x-x2) > self.w do
		self.scrollCaret = self.scrollCaret + 1
		x2, y2 = self:caretToPixel( self.scrollCaret )
	end
end

function panel:scrollLeft()
	if self.multiline then return end
	if( self:getCaret() < self.scrollCaret ) then
		self.scrollCaret = self:getCaret()
	end
end




function panel:setCaret( newcaret, sel )
	self.selection[sel and 2 or 1] = math.min( math.max( newcaret, sel and -1 or 0 ), self:length() )
	if not sel then
		--self:scrollIntoView()
		--self.renderOffset[1] = 0
		--self.renderOffset[2] = math.floor( Y/(self:getHeight()-20)) * -(self:getHeight()-20)
	end
end

function panel:nextSpace( dir )
	if dir then
		local found = self.text:find( '%s+', self:getCaret() + 1 )--search until we found a whitespace
		if not found then return #self.text end
		found = self.text:find( '%S', found )--search until we found a non whitespace
		return (found or #self.text) - 1
	else
		local reverse = self.text:reverse() .. ' '
		local found = reverse:find( '%S+', #self.text - self:getCaret() + 1 )--search until we found a non whitespace
		if not found then return 0 end
		found = reverse:find( '%s', found )--search until we found a whitespace
		if not found then return 0 end
		return #self.text - found + 1
	end
end

function panel:setPattern( pattern ) self.pattern = pattern end
function panel:deny()
	audio.play( "gui/deny.ogg" )
	tween.remove( self.badMatchAnim )
	self.badMatchColor = 0
	self.badMatchAnim = tween.new( self, {badMatchColor=1}, .2, 'outCubic', function()
		self.badMatchAnim = tween.new( self, {badMatchColor=0}, .2, 'outCubic', function()
			self.badMatchColor = nil
			self.badMatchAnim = nil
		end )
	end )
end
function panel:ontextinput( txt )
	if self.pattern and not txt:find(self.pattern) then
		self:deny()
		return
	end
	self.ime = ''
	self.textIME = nil
	self:insert( txt )
	self.doDeselect = false
end

function panel:onime( text )
	self.ime = text
end

function panel:selectAll()
	self:setCaret( #self.text )
	self:setCaret( 0, true )
	self:scrollRight()
end

function panel:getSelectedText()
	return self:substr( order(self:getCaret() + 1, self:getCaret( true ), true) )
end

local function selectionTest( self, mods )
	if input.hasModifier( mods, MOD_SHIFT ) and not self:hasSelection() then
		self:setCaret( self:getCaret( ), true )
	end
end
function panel:onkeypress( key, mods )
	--MODIFIERS
	if input.hasModifier( mods, MOD_CTRL ) then
		if self:getMask() then return end
		if( key == sdl.KEY_a ) then
			self:selectAll()
		elseif( key == sdl.KEY_c ) then
			system.setClipboardText(self:getSelectedText())
		elseif( key == sdl.KEY_x ) then
			if self:hasSelection() then
				system.setClipboardText( self:getSelectedText() )
				self:deleteSelection()
			end
		elseif( key == sdl.KEY_v ) then
			if self:hasSelection() then self:deleteSelection() end
			local txt = system.getClipboardText()
			if self.pattern then
				local pattern
				if(self.pattern:sub(1,1) == "[") then
					pattern = "[^" .. self.pattern:sub(2)
				else
					pattern = "[^" .. self.pattern .. "]"
				end
				txt = txt:gsub(pattern, "")
			end
			self:insert( txt )
		end
		
	end
	local y= select(2,self:getCaretXY())
	if( key == sdl.KEY_RETURN or key == sdl.KEY_KP_ENTER ) then
		if self.multiline then
			self:insert( '\n' )
		else self:onenter( self.text ) end
	elseif( key == sdl.KEY_BACKSPACE ) then
		self:delete( -1 )
		
	elseif( key == sdl.KEY_HOME ) then
		selectionTest( self, mods )
		local x,y=self:getCaretXY()
		self:moveCursor( -math.huge, y )
		self:scrollLeft()
	elseif( key == sdl.KEY_END ) then
		selectionTest( self, mods )
		local x,y=self:getCaretXY()
		self:moveCursor( math.huge, y )
		self:scrollRight()
	elseif( key == sdl.KEY_LEFT ) then
		selectionTest( self, mods )
		if input.hasModifier( mods, MOD_CTRL ) then
			local sp = self:nextSpace()
			self:setCaret( sp and sp or self:getCaret())
		else
			self:setCaret( self:getCaret() - 1 )
		end
		self:scrollLeft()
	elseif( key == sdl.KEY_RIGHT ) then
		selectionTest( self, mods )
		if input.hasModifier( mods, MOD_CTRL ) then
			local sp = self:nextSpace(true)
			self:setCaret( sp and sp or self:getCaret())
		else
			self:setCaret( self:getCaret() + 1 )
		end
		self:scrollRight()
	elseif( key == sdl.KEY_DELETE ) then
		self:delete( 1 )
	elseif( key == sdl.KEY_UP ) then
		selectionTest( self, mods )
		local x, y = self:getCaretXY()
		self:moveCursor( x, y - 1 )
	elseif( key == sdl.KEY_DOWN ) then
		selectionTest( self, mods )
		local x, y = self:getCaretXY()
		self:moveCursor( x, y + 1 )
	end if( mods == 0 and (key ~= sdl.KEY_LSHIFT and key ~= sdl.KEY_RSHIFT and key ~= sdl.KEY_LCTRL and key ~= sdl.KEY_RCTRL and key ~= sdl.KEY_LALT and key ~= sdl.KEY_RALT) ) then
		self.doDeselect = true--must defer...
	end
end

function panel:getRenderOffset()
	if( self.multiline ) then
		local x, y = self.w, self.h
		local vx, vy = self:caretToPixel( self:getCaret() )
		while( vx > x ) do
			x = x + self.w/2
		end
		while( vy > y - self.font:getHeight()/2 ) do
			y = y + self.h/2
		end
		return -x + self.w, -y + self.h + self.font:getHeight()/2
	end
		
	local x, y = self:caretToPixel( self.scrollCaret )
	return -x, -y + self.font:getHeight()
end

function panel:pixelToCaret( x, y )
	local rX, rY = self:getRenderOffset()
	x = x - rX
	local w = 0
	if not self.multiline then
		for i = 0, self:length() - 1 do
			local cw = self.font:getCharSize( self:charAt( i ) )
			w = w + cw
			if( w > x + cw ) then return i - 1 end
			if( w > x + cw / 2 ) then return i end
		end
		return self:length()
	else
		y = y - rY
		local h = self:getYStart()/2
		local curLineBreak = 1
		local onRightLine = false
		for i = 0, self:length() - 1 do
			if( self.lineBreaks[ curLineBreak ].last == i - 1 ) then
				curLineBreak = curLineBreak + 1
				w = 2
				h = h + self.font:getHeight()
				if onRightLine then return i end
			end
			if( y < self:getYStart() ) then onRightLine = true
			elseif  y >= h and y < (h + self.font:getHeight() + 1) then onRightLine = true end
			local cw = self.font:getCharSize( self:charAt( i ) )
			if onRightLine then
				if x > self:getWidth() then
				elseif x < 2 or y < self:getYStart() then
					return i
				end
				if x >= w and x < w + cw then
					if x < (x + cw * 0.5) then return i else return i + 1 end
				end
			end
			w = w + cw
		end
		return self:length()
	end
end

function panel:onmousedown( key, x, y )
	if( key == MOUSE_LEFT ) then
		self:setCaret( self:pixelToCaret( x, y ) )
		self:deselect()
	end
end

function panel:onmouseup( key, x, y )
	if( key == MOUSE_RIGHT ) then
		--todo: context menu
	end
end

function panel:onmousemove( x, y )
	if self.depressed then
		if not self:hasSelection() then
			self:setCaret( self:getCaret(), true )
		else
			if( y < 0 ) then
				y = -1
			elseif( y > self.h ) then
				y = 1
			end
			if( x < 0 ) then
				x = -1
			elseif( x > self.w ) then
				x = 1
			end
			self:setCaret( self:pixelToCaret( x, y ) )
			if( x < 0 ) then
				self:scrollLeft()
			elseif( x > self.w ) then
				self:scrollRight()
			end
		end
	end
end

function panel:onenter( text ) end

return panel
