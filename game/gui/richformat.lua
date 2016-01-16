local string = string
local os = os
local table = table
local ipairs = ipairs
local setmetatable = setmetatable
local math = math
local Color = Color
local tostring = tostring
local pairs=pairs
local print = print
local PrintTable = PrintTable --todo
local pcall = pcall
local bit = bit
local color_white,color_blue=color_white,color_blue
local color_white,color_blue=color_white,color_blue
local surface = surface
function table.copy( tbl )
	local ret = {}
	for k,v in pairs( tbl ) do
		if( type( v ) == "table" ) then
			ret[ k ] = table.copy( v )
		else
			ret[ k ] = v
		end
	end
	return ret
end


local M = {}
function table.count( tbl )
	local cnt = 0
	for k,v in pairs( tbl ) do cnt = cnt + 1 end
	return cnt
end
function math.clamp(val,min,max)
    return math.min(math.max(val,min),max)
end
local font = surface.primaryFont-- or love.graphics.newFont( 12 )


--[[surface.CreateFont( "Breakpoint - Chat", {
	font = "Trebuchet MS",
	size = 22,
	weight = 1000,
	antialias = true,
} )

surface.CreateFont( "Breakpoint - Chat URL", {
	font = "Trebuchet MS",
	size = 22,
	weight = 2000,
	antialias = true,
	underline = true,
} )]]

local CharWidth = {}
local RichObject = {}

function RichObject:Create(w,h,lc)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.font = font

	o.buffer = ""
	o.styles = {}
	o.parsedstyles = {}
	o.lines = nil

	o.width, o.height = w, h
	o.totalheight = 0
	o.maxlines = lc

	o.numlines = 0

	o.X, o.Y = 0, 0
	o.scroll = 0

	o.cfilter = 0

	o.drawbounds = {0, 0}

	o.selection = {}

	return o
end

function RichObject:BuildWidthCache(font)
	if not CharWidth[font] then
		CharWidth[font] = {}
		for i=1,127 do
			local c = string.char(i)
			CharWidth[font][c] = font:getCharSize(c)
		end
		--CharWidth[font]["&"] = CharWidth[font]["^"] // & is 0 width
	end
end

function RichObject:CalcTextSizeEx(buffer, font)
	--local buff = string.gsub(buffer, "&", "^")
	return font:getTextSize(buffer)
end

function RichObject:CalcCharWidthExtended(font, str, pos, maxpos)
		local c = string.sub(str, pos, pos)

		if CharWidth[font][c] then
			return CharWidth[font][c], c, pos
		end

		local byte = string.byte(c)
		if byte < 194 or byte > 244 or pos == maxpos then
			return 0, c, pos
		end

		pos = pos + 1
		local c2 = string.sub(str, pos, pos)
		byte = string.byte(c2)

		while byte >= 128 and byte <= 191 do
			c = c .. c2
			pos = pos + 1
			if pos > maxpos then break end

			c2 = string.sub(str, pos, pos)
			byte = string.byte(c2)
		end

		if CharWidth[font][c] then
			return CharWidth[font][c], c, pos-1
		end

		CharWidth[font][c] = font:getWidth( c )
		return CharWidth[font][c], c, pos-1
end

function RichObject:BuildStyle(pos, length, color, font, time, onclick, onclickref, filter, newline)
	local style = {}

	style.pos = pos
	style.length = length

	style.color = color
	style.font = font
	style.time = time
	style.newline = newline

	style.onclick = onclick
	style.onclickref = onclickref

	style.filter = filter
	-- surface.SetFont(font)

	local buffer = string.sub(self.buffer, pos, pos + length - 1)
	buffer = string.gsub(buffer, "\n", "")

	style.xwidth, style.yheight = self:CalcTextSizeEx(buffer, font)

	return style
end

function RichObject:Add(text, color, font, time, onclick, onclickref, filter, newline, renderOptions)
	if not color then color = onclick and color_blue or color_white end --wtf
	if not font then font = self.font end
	if not time then time = os.clock() end
	if not filter then filter = 0 end
	text=tostring(text)
	self:BuildWidthCache(font)

	local p = 1

	if not newline then
		for i = 1, #text do
			if string.sub(text, i, i) == "\n" then
				self:Add(string.sub(text, p, i), color, font, time, onclick, onclickref, filter, true)
				p = i + 1
			end
		end
	else
		self.numlines = self.numlines + 1
	end

	if self.maxlines and ( self.numlines > self.maxlines ) then

		local blk
		repeat
			blk = table.remove(self.styles, 1)
		until blk.newline == true

		local pos = blk.pos + blk.length - 1
		self.buffer = string.sub(self.buffer, pos + 1)

		for k, v in ipairs(self.styles) do
			v.pos = v.pos - pos
		end

		local s, e = self:GetSelection()
		if s > 0 and e > 0 then
			self.selection[1], self.selection[2] = s-pos, e-pos
		end

		self.numlines = self.numlines - 1
	end

	text = string.sub(text, p)

	if #text == 0 and not (renderOptions and renderOptions.icon) then return end

	local pos = #self.buffer + 1
	self.buffer = self.buffer .. text

	local style = self:BuildStyle(pos, #text, color, font, time, onclick, onclickref, filter, newline)
	style.renderOptions=renderOptions
	table.insert(self.styles, style)

	self:Parse()
end

function RichObject:NewLine(ypos)
	local nl = {firstsyle=nil, ypos=ypos, xwidth=0, yheight=0}
	table.insert(self.lines, nl)

	return nl
end

function RichObject:AssociateStyleWithLine(style, line)
	style.line = line
	style.xpos = line.xwidth
	if(style.renderOptions and style.renderOptions.icon) then
		line.xwidth=line.xwidth+(style.renderOptions.iconspacing or 20)
		style.xpos=style.xpos+(style.renderOptions.iconspacing or 20)
	end
	local index = table.insert(self.parsedstyles, style)

	if not line.firststyle then
		line.firststyle = table.count(self.parsedstyles)
	end

	line.yheight = math.max(line.yheight, style.yheight)
	line.xwidth = line.xwidth + style.xwidth

	if style.newline then
		return self:NewLine(line.ypos + line.yheight + 2)
	end

	return line
end

function RichObject:Parse()

	self.parsedstyles = {}
	self.lines = {}

	local currentline = self:NewLine(0)

	for k, v in ipairs(self.styles) do

		--if not (bit.band(v.filter,self.cfilter) > 0) then

		if currentline.xwidth + v.xwidth <= self.width then

			if currentline.xwidth + v.xwidth == self.width then
				v = table.copy(v)
				v.newline = true
			end

			currentline = self:AssociateStyleWithLine(v, currentline)

		else

			local cw = currentline.xwidth
			local pos = v.pos

			local i, lte = 0, v.length - 1
			while i <= lte do
				local cpos = v.pos + i
				local c, ch, cpos = self:CalcCharWidthExtended(v.font, self.buffer, cpos, v.pos + lte)
				i = cpos - v.pos

				local chc = cw + c

				local wordwrap = false

				if ch == " " then
					local wpos = string.find(self.buffer, " ", cpos + 1)
					if not wpos then
						wpos = v.pos + lte
					end

					local width = self:GetPixelOffsetPos(v, wpos, true, i)

					if cw + width > self.width then
						cpos = cpos + 1
						wordwrap = true
					end
				end

				if chc <= self.width and not wordwrap then
					cw = chc
				else
					local style = self:BuildStyle(pos, cpos - pos, v.color, v.font, v.time, v.onclick, v.onclickref, v.filter, true)

					currentline = self:AssociateStyleWithLine(style, currentline)

					pos = cpos
					cw = c
				end

				i = i + 1
			end

			if pos < v.pos + v.length then
				local style = self:BuildStyle(pos, (v.pos + v.length) - pos, v.color, v.font, v.time, v.onclick, v.onclickref, v.filter, v.newline)

				currentline = self:AssociateStyleWithLine(style, currentline)
			end

		end

		--end
	end

	if not currentline.firststyle then
		local l = table.remove(self.lines, table.maxn(self.lines))
		self.totalheight = l.ypos
	else
		self.totalheight = currentline.ypos + currentline.yheight
	end

	self:CalcDraw()
end

function RichObject:CalcDraw()
	self.drawbounds[1] = 0
	self.drawbounds[2] = 0

	if not self.lines or #self.lines == 0 then return end

	for k,l in ipairs(self.lines) do
		if self.drawbounds[1] == 0 and l.ypos + l.yheight > self.scroll then
			self.drawbounds[1] = l.firststyle
		elseif l.ypos > (self.height + self.scroll) then
			self.drawbounds[2] = l.firststyle - 1
			break
		end
	end

	if self.drawbounds[2] <= 0 then
		self.drawbounds[2] = #self.parsedstyles
	end
end

function RichObject:SetFilter(x)
	self.cfilter = x
	self:Parse()
end

function RichObject:GetFilter()
	return self.cfilter
end

function RichObject:SetSize(w, h)
	if w == self.width and h == self.height then return end
	self.width, self.height = w, h
	self:Parse()
end

function RichObject:SetPos(x, y)
	self.X, self.Y = x,y
end
function RichObject:GetScroll( )
	return self.scroll
end
function RichObject:SetScroll(scroll)
	if scroll < 0 then scroll = 0 end
	self.scroll = scroll

	self:CalcDraw()
end

function RichObject:GetTotalHeight()
	return self.totalheight
end

function RichObject:GetPixelOffsetPos(block, pos, endof, start)
	local w = 0
	if not start then start = 0 end

	local i, lte = start, block.length - 1
	while i <= lte do
		local p = block.pos + i

		if not endof and p == pos then break end

		local c, ch, n = self:CalcCharWidthExtended(block.font, self.buffer, p, block.pos + lte)
		i = n - block.pos

		w = w + c

		if endof and p == pos then break end
		i = i + 1
	end
	return w
end

function RichObject:DrawSelection(block)
	local s, e = self:GetSelection()
	if s > block.pos + block.length - 1 or e < block.pos then
		return
	end

	local start = 0
	local endpx = block.xwidth

	if s >= block.pos and s <= block.pos + block.length - 1 then
		start = self:GetPixelOffsetPos(block, s)
	end
	if e >= block.pos and e <= block.pos + block.length - 1 then
		endpx = self:GetPixelOffsetPos(block, e, true)
	end

	surface.setDrawColor( 50, 50, 200 )
	surface.fillRect(self.X + block.xpos + start, self.Y + block.line.ypos - self.scroll, endpx - start, block.yheight)
end

local matCache={}
function RichObject:Draw(fade)
	local stay = 10
	local curtime = os.clock()
	if(not self.drawbounds[1] or not self.drawbounds[2]) then self.drawbounds={0,0} return end
	if self.drawbounds[1] == 0 or self.drawbounds[2] == 0 then return end
	for i=self.drawbounds[1], self.drawbounds[2] do
	--for i=1, #self.parsedstyles do
		local block = self.parsedstyles[i]

		if not block then
			PrintTable(self.drawbounds)
			PrintTable(self.parsedstyles)
			Error("tried to draw")
		end

		local buffer = string.sub(self.buffer, block.pos, block.pos + block.length - 1)

		local s, e = self:GetSelection()

		if s > 0 and e > 0 then
			self:DrawSelection(block)
		end
		local a = block.color.a

		if fade and curtime > block.time + stay then
			local delta = (curtime - (block.time + stay))
			if delta <= 1 then
				a = 255 * (1 - delta)
			else
				a = 0
			end
		end

		if a > 0 then
			local mat
			--surface.SetFont(block.font)

			surface.setFont( block.font )
			local col=block.color
			if(block.renderOptions) then
				if(block.renderOptions.getColor) then
					col=block.renderOptions.getColor(block) or color_white
				end
				mat=block.renderOptions.icon
				if(mat) then
					error( "Unsupported." )
					if(not matCache[mat]) then matCache[mat]=Material(mat,block.renderOptions.matsettings) end
					mat=matCache[mat]
				end
			end
			local x, y = self.X + block.xpos, self.Y + block.line.ypos - self.scroll
			if(mat) then
				error( "Unsupported." )
				surface.SetMaterial(mat)
				local rankcol=block.renderOptions.iconcolor or color_white
				surface.SetDrawColor(rankcol.r,rankcol.g,rankcol.b,a)

				if block.renderOptions.rotating then
					surface.DrawTexturedRectRotated((x-(block.renderOptions.iconspacing or 20))+8,(y+4)+8,block.renderOptions.width or 16,block.renderOptions.height or 16,os.clock()*(block.renderOptions.rotating or 45))
				else
					surface.DrawTexturedRect(x-(block.renderOptions.iconspacing or 20),y+4,block.renderOptions.width or 16,block.renderOptions.height or 16)
				end

			end

			surface.setDrawColor( 200, 200, 200, math.clamp(a - 50, 0, 255) )
            surface.setTextureColor( 200, 200, 200 )

			if( block.onclick ) then
				surface.drawLine( x + 1, y + 1 + block.line.yheight, x + 1 + block.xwidth, y + 1 + block.line.yheight )
			end
            surface.setTextColor( 0, 0, 0, math.clamp(a - 50, 0, 255) )
            surface.drawText( buffer, x + 1, y + 1 )
            surface.setAlphaMultiplier(1)
			surface.setDrawColor( col )
            surface.setTextColor( col.r, col.g, col.b, col.a )

			if( block.onclick ) then
				surface.drawLine( x, y + block.line.yheight, x + block.xwidth, y + block.line.yheight )
			end

			surface.drawText( buffer, x, y )
		end
	end
end

function RichObject:GetStyleForPosition(pos, exact)
	local bestblock = 0

	if self.drawbounds[1] == 0 or self.drawbounds[2] == 0 then return nil, 0 end

	if pos.y < self.Y then pos.y = self.Y end
	if pos.x < self.X then pos.x = self.X end

	for i=self.drawbounds[1], self.drawbounds[2] do
		local block = self.parsedstyles[i]

		local bypos = self.Y + block.line.ypos - self.scroll
		local bxpos = self.X + block.xpos

		if pos.y >= bypos and pos.x >= bxpos and (not exact or pos.y <= bypos + block.yheight) then
			bestblock = i
		end
	end

	if bestblock == 0 then return nil, 0 end

	local bblock = self.parsedstyles[bestblock]
	local cw = self.X + bblock.xpos

	local i, lte = 0, bblock.length-1
	while i <= lte do
		local p = bblock.pos + i

		local c, ch, n = self:CalcCharWidthExtended(bblock.font, self.buffer, p, bblock.pos + lte)
		i = n - bblock.pos

		if pos.x >= cw and pos.x <= cw + c then
			return bblock, p
		end

		cw = cw + c
		i = i + 1
	end

	return bblock, bblock.pos + bblock.length - 1
end

function RichObject:DoClick(pos)
	local block, pos = self:GetStyleForPosition(pos, true)

	if block and block.onclick then
		pcall(block.onclick, string.sub(self.buffer, block.pos, block.pos + block.length - 1), block.onclickref)
	end
end

function RichObject:GetCursor(pos)
	local block, pos = self:GetStyleForPosition(pos, true)

	local selstart, selend = self:GetSelection( )
	--if( not love.mouse.isDown('l') and selstart~=0 and selend~=0 and selstart <= pos and selend >= pos ) then
	--	return "arrow"
	--end

	if block and block.onclick then
		return "hand"
	end
	return "ibeam"
end

function RichObject:ClearSelection()
	self.selection[1], self.selection[2] = 0, 0
end

function RichObject:SetSelectionStart(pos)
	local block, pos = self:GetStyleForPosition(pos)
	self.selection[1] = pos
	self.selection[2] = 0
end

function RichObject:SetSelectionEnd(pos)
	local block, pos = self:GetStyleForPosition(pos)
	self.selection[2] = pos
end

function RichObject:GetSelection()
	if not self.selection[1] or not self.selection[2] then return 0,0 end

	if self.selection[1] > self.selection[2] then
		return self.selection[2], self.selection[1]
	end
	return self.selection[1], self.selection[2]
end

function RichObject:GetSelectedText()
	local s, e = self:GetSelection()
	if s == 0 or e == 0 then return "" end

	local buffer = ""

	for i=self.drawbounds[1], self.drawbounds[2] do
		local block = self.parsedstyles[i]

		if s <= block.pos + block.length - 1 and e >= block.pos then
			local start = block.pos
			local endpos = start + block.length - 1

			if s >= block.pos and s <= block.pos + block.length - 1 then
				start = s
			end

			if e >= block.pos and e <= block.pos + block.length - 1 then
				local c, ch, p = self:CalcCharWidthExtended(block.font, self.buffer, e, block.pos + block.length - 1)
				endpos = p
			end

			buffer = buffer .. string.sub(self.buffer, start, endpos)
		end
	end

	return buffer
end

function M.New(w,h, lc)
	return RichObject:Create(w,h,lc)
end
return M
