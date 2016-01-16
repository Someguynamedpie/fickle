local gui = ...
local panel = class( "gui.OSK", "gui.Frame" )
local qwerty = {
	{
		"~!@#$%^&*()_+\b",
		"`1234567890-=\b",
		"§             "
	},
	{
		"\tQWERTYUIOP{}|",
		"\tqwertyuiop[]\\",
	},
	{
		"\2ASDFGHJKL:\"\n",
		"\2asdfghjkl;'\n",
	},
	{
		"\1ZXCVBNM<>?\1",
		"\1zxcvbnm,./\1",
	},
	{
		"   ",
		"   ",
	}
}
local dvorak = {
	{
		"~!@#$%^&*(){}\b",
		"`1234567890[]\b",
	},
	{
		"\t\"<>PYFGCRL?+=",
		"\t',.pyfgcrl/=\\"
	},
	{
		"\2AOEUIDHTNS_\n",
		"\2aoeuidhtns-\n",
	},
	{
		"\1:QJKXBMWVZ\1",
		"\1;qjkxbmwvz\1",
	},
	{
		"\3  \3",
		"\3  \3"
	}
}


local layouts = {
	qwerty = qwerty,
	dvorak = dvorak,
	svorak = svorak
}
local alt = {
	['\t'] = "Tab",
	['\b'] = "Backspace",
	['\n'] = "  Enter ",
	['\2'] = "Caps",
	['\1'] = "Shift",
	['\3'] = " Alt Gr",
	[' '] = "       Spacebar       "
}
function panel:rebuild()
	if self.keys then for k1, v1 in ipairs( self.keys ) do for k2, v2 in ipairs(v1) do v2:remove() end end end
	self.keys = {}
	local layout = self.layout
	
	self:setSize( 500, #layout * 32 + 24 )
	
	local y = -8
	local keys = {} self.keys = keys
	local width = 0
	for Y, row in ipairs( layout ) do
		x = 0
		y = y + 32
		local tW = 0
		keys[ Y ] = {}
		local keysShift = row[1]
		local keysNormal = row[2]
		local keysGr = row[3]
		for i = 1, #keysNormal do
			local k = keysNormal:utf8sub(i,i)
			local ok = k
			if alt[k] then k = alt[k] end
			local k2 = keysShift:utf8sub(i,i)
			if alt[k2] then k2 = alt[k2] end
			
			local k3 = keysGr and keysGr:utf8sub( i, i ) or ''
			
			local btn = gui.new( 'button', self )
			keys[Y][i] = btn
			
			btn:setText( ((k2 ~= k:upper() and k2 ~= k) and k2 .. '\n' or '') .. k .. '  ' .. k3 )
			local w = math.max( surface.getTextSize( k ), surface.getTextSize( k2 ) ) + 4
			btn:setSize( w + 4, 32 )
			btn:setPos( x, y )
			self.ow = w + 8
			self.oh = 32
			btn.ox = x
			btn.oy = btn.y
			btn:align( ALIGN_CENTER )
			x = x + btn:getWidth() + 4
			if x > width then width = x end
			if x > tW then tW = x end
			
			--io.write(tostring(k) .. '/' .. tostring(k2) .. '\n')
			btn.k1 = k
			btn.k2 = k2
			btn.ok = ok
			
			if ok == '\1' then
				btn.ontoggle = self.setShifting
				btn:setTogglable( true )
			elseif ok == '\2' then
				btn.ontoggle = self.setCapslock
				btn:setTogglable( true )
			end
			
		end
		keys[ Y ].width = tW - 4
	end
	self:setWidth( width - 4 )
	for Y, row in ipairs( self.keys ) do
		local multiplierX = self:getWidth() / row.width
		local multiplierY = self:getHeight() / (#layout * 32 + 24)
		
		for X, btn in ipairs( row ) do
			btn.x = btn.ox * multiplierX
			btn.y = btn.oy * multiplierY
			
		end
	end
	
end
function panel:setLayout( name )
	self.layout = layouts[ name ]
	self:rebuild()
end
function panel:relabelButtons()
	for Y, row in ipairs( self.keys ) do
		for X, btn in ipairs( row ) do
			if( btn.ok == '\2' ) then
				btn.toggled = self.capslock
			elseif btn.ok == '\1' then
				btn.toggled = self.shifting
			end
			local k1, k2 = btn.k1, btn.k2
			local n = k1
			local showAlt = not(k1 == k2 or k1:upper() == k2:upper() or k1:upper() ~= k1)
			if self.capslock ~= self.shifting then k1, k2 = k2, k1 end
			btn:setText( (showAlt and k2 .. '\n' or '') .. k1 )
		end
	end
end
function panel:setShifting( shifting )
	self.parent.shifting = shifting
	self.parent:relabelButtons()
end
function panel:setCapslock( capslock )
	self.parent.capslock = capslock
	self.parent:relabelButtons()
end
function panel:init()
	self.shifting = false self.capslock = false
	self.baseclass.init( self )
	self:setLayout'qwerty'
	self.handle:remove()
	self:setTitle( "On Screen Keyboard" )
	
	local dropdown = gui.new( "dropdown", self )
	dropdown:makePopup()
	dropdown:setSize( 128, 23 )
	
	for k, v in pairs( layouts ) do
		dropdown:addItem( k )
	end
	function dropdown.onselect(_,v)
		self:setLayout(v)
	end
	dropdown:bringToFront()
end
function panel:onlayout()
	
end
return panel
	