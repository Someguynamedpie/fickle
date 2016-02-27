local ft = require( 'lib.freetype' )
local ffi = require'ffi'


local library = ffi.new( 'FT_Library[1]' )
print'initting freetype...'
if not ft.Init_FreeType( library ) then
	error( "FreeType would NOT initiate!" )
end
print'initted.'
local function getCodepoint(utf8str)
	local A,B,C,D

	local res, seq, val = {}, 0, nil
	for i = 1, #utf8str do
		local c = string.byte(utf8str, i)
		if seq == 0 then
			if not A then
				A = val
			elseif not B then B = val elseif not C then C = val elseif not D then D = val end
			seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
			      c < 0xF8 and 4 or --c < 0xFC and 5 or c < 0xFE and 6 or
				  error("invalid UTF-8 character sequence")
			val = bit.band(c, 2^(8-seq) - 1)
		else
			val = bit.bor(bit.lshift(val, 6), bit.band(c, 0x3F))
		end
		seq = seq - 1
	end
	if not A then
		A = val
	elseif not B then B = val elseif not C then C = val elseif not D then D = val end
	val = 0
	if not A then
		A = val
	elseif not B then B = val elseif not C then C = val elseif not D then D = val end
	A = A or 0 B = B or 0 C = C or 0 D = D or 0
	return bit.lshift( D, 24 ) + bit.lshift( C, 16 ) + bit.lshift( B, 8 ) + A
end

local meta = {}
function meta:loadGlyphs( cpStart, cpEnd )
	local glyph = ffi.new( 'FT_Glyph[1]' )
	for i = cpStart, cpEnd do

		local err = ft.Load_Glyph( self.face, ft.Get_Char_Index( self.face, i ), ft.LOAD_DEFAULT )
		if err ~= 0 then
			self.glyphs[ i ] = { valid = false }
			--error( "FT_Load_Glyph Error: " .. err )
		else

		err = ft.Get_Glyph( self.face.glyph, glyph )
		if err ~= 0 then
			error( "FT_Get_Glyph Error: " .. err )
		end

		ft.Glyph_To_Bitmap( glyph, ft.RENDER_MODE_NORMAL, nil, 1 )
		local bitmapglyph = ffi.cast( 'FT_BitmapGlyph', glyph[ 0 ] )
		local bitmap = bitmapglyph.bitmap
		local page, node = self.atlas:findFreePage( bitmap.width, bitmap.rows )
		if not page.texture then
			page.texture = CreateTexture( 512, 512, sdl.PIXELFORMAT_ABGR8888, TEXTURE_STREAMING, sdl.BLENDMODE_BLEND )
			local tex, pitch = page.texture:lock( node.x, node.y, bitmap.width, bitmap.rows )
			--ffi.fill(tex,512*pitch, 0xFF)
			page.texture:unlock()
		end
		local char = {
			bearingX = bitmapglyph.left,
			bearingY = bitmapglyph.top,
			height = bitmap.rows,
			width = bitmap.width,
			xAdvance = glyph[ 0 ].advance.x / 65535,
			yAdvance = glyph[ 0 ].advance.y / 65535,
			node = node,
			valid= true,

			texture = page.texture
		}
		self.glyphs[ i ] = char
		--[[ft.Load_Char( self.face, i, ft.LOAD_RENDER )
		local slot = self.face.glyph
		local bitmap = slot.bitmap
		local page, node = self.atlas:findFreePage( bitmap.width, bitmap.rows )
		if not page.texture then
			page.texture = sdl.CreateTexture( video.renderer, sdl.PIXELFORMAT_RGBA8888, sdl.TEXTUREACCESS_STATIC, 512, 512 )
			sdl.SetTextureBlendMode( page.texture, sdl.BLENDMODE_BLEND )
		end
		local bmpGlyph = ffi.cast( 'FT_BitmapGlyph*',
		self.glyphs[ i ] = {texture = {tex=page.texture}, node = node, w = bitmap.width, h = bitmap.rows, xadv = math.floor( tonumber(slot.advance.x) / 64 ), yadv = math.floor( tonumber(slot.advance.y) / 64 ), bx =  }]]
		local tex, pitch = page.texture:lock( node.x, node.y, node.w, node.h )
		local pixels = bitmap.buffer
		--ffi.fill( tex, node.h * pitch, 0xFF )

		for y = 0, bitmap.rows - 1 do
			for x = 0, bitmap.width - 1 do

				--if(bitmap.buffer[ i ] > 0) then io.write('x') else io.write(' ') end
				--if i % bitmap.width == 0 then io.write'\n' end
				local alpha = 0

				if bitmap.pixel_mode == ft.PIXEL_MODE_MONO then
					alpha = (bit.band( (pixels[math.floor(x / 8)]), bit.lshift( 1, 7 - x % 8 ) ) ) > 0 and 0xFF or 0
				elseif bitmap.pixel_mode == ft.PIXEL_MODE_GRAY then
					alpha = pixels[ x ]
				end
				local base = 4 * x
				tex[ base + 0 ] = 0xFF
				tex[ base + 1 ] = 0xFF
				tex[ base + 2 ] = 0xFF
				tex[ base + 3 ] = alpha
			end
			pixels = pixels + bitmap.pitch
			tex = tex + pitch
		end
		page.texture:unlock()
		ft.Done_Glyph( glyph[ 0 ] )
		end
		--sdl.UpdateTexture( page.texture, surface.getRect( node.x, node.y, bitmap.width, bitmap.rows ), pixels, bitmap.width * 4 )
	end
end

function meta:getCharSize( char )
	local idx = getCodepoint( char )
	local ch = self.glyphs[ idx ]
	if not ch then
		self:loadGlyphs( idx, idx )
		ch = self.glyphs[ idx ]
	end
	return ch.xAdvance, ch.yAdvance
end

function meta:getHeight()
	return self.lineHeight
end

local hack = ffi.new( "union{struct{unsigned char a; unsigned char b; unsigned char c; unsigned char d;}; unsigned int utf;}" )
local strchar = string.char
function meta:getTextSize( str )
	local maxWidth = 0
	local width = 0
	local height = self.lineHeight
	local chNL = 0
	for i = 1, str:utf8len() do
		local ch = getCodepoint(str:utf8sub( i, i ))

		if ch == 10 then
			if width < maxWidth then
				maxWidth = width
			end
			width = 0
			height = height + self.lineHeight
		else
			local char = self.glyphs[ ch ]
			if char and char.valid then
				chNL = chNL + 1

				local kX = 0
				if( chNL > 1 ) then
					if self.hasKerning then
						ft.Get_Kerning( face, ft.Get_Char_Index( face, str:byte( i-1, i-1 ) ), ft.Get_Char_Index(face, idx), ft.KERNING_DEFAULT, delta )
						kX = delta[0].x/64
					end
				end

				width = width + kX + char.xAdvance
			end
		end
	end
	if width > maxWidth then maxWidth = width end
	return maxWidth, height
end

local delta = ffi.new('FT_Vector[1]')
function meta:drawChar( ch, x, y, optimize )
	local idx = getCodepoint( ch )
	local char = self.glyphs[ idx ]
	if not char then
		self:loadGlyphs( idx, idx )
		char = self.glyphs[ idx ]
	end
	if char and char.valid then
		if char.texture ~= optimize then
			surface.setTexture( char.texture )
		end
		local node = char.node

		surface.drawTexturedSubrect( x + char.bearingX, y + self.baseline - char.bearingY, char.width, char.height, node.x, node.y, char.width, char.height )
		return char.xAdvance, char.yAdvance, char.texture
	end
	return 0, 0, optimize
end

function meta:draw( str, x, y )
	local X, Y = x, y
	local exPage
	for i = 1, str:utf8len() do
		local idx= getCodepoint(str:utf8sub( i, i ))

		if idx == 10 then
			X = x
			Y = Y + self.lineHeight
		else
			local char = self.glyphs[ idx ]
			if not char then
				self:loadGlyphs( idx, idx )
				print'hotloaded a glyph'
				char = self.glyphs[ idx ]
			end
			if char and char.valid then
				if exPage ~= char.texture then
					exPage = char.texture
					surface.setTexture( exPage )
					surface.setTextureColor(surface.fontR or 255, surface.fontG or 255, surface.fontB or 255, surface.fontA)
				end

				local node = char.node
				local kX = 0
				if( i > 1 ) then
					if self.hasKerning then
						ft.Get_Kerning( face, ft.Get_Char_Index( face, str:byte( i-1, i-1 ) ), ft.Get_Char_Index(face, idx), ft.KERNING_DEFAULT, delta )
						kX = delta[0].x/64
					end

				end

				--surface.setDrawColor(255,0,0,128)
				--surface.fillRect( node.x, node.y, node.w, node.h )
				--surface.drawTexturedRect( 0, 0, 512, 512 )
				surface.drawTexturedSubrect( X + kX + char.bearingX, Y + self.baseline - char.bearingY, char.width, char.height, node.x, node.y, char.width, char.height )
				X = X + char.xAdvance
				Y = Y + char.yAdvance
			end
		end
	end
end

meta.__index = meta

local M = {}
function M.loadFont( path, options )
	local face = ffi.new( 'FT_Face[1]' )
	local err = ft.New_Face( library[0], "fonts/" .. path, 0, face )
	if( err ~= 0 ) then
		error("Failed to load font " .. path .. ": "..err)
	end
	face = face[0]
	ft.Set_Pixel_Sizes( face, 0, (options or {size=25}).size )
	local metrics = face.size.metrics
	ft.Select_Charmap( face, ft.ENCODING_UNICODE )
	local font = setmetatable( {glyphs = {}, atlas = CreateAtlas( 512, 512 ), face = face,
		ascent = metrics.ascender / 64,
		descent = metrics.descender / 64,
		lineHeight = metrics.height / 64,
		baseline   =  metrics.height / 64 / 1.25 + 0.5,
		hasKerning = bit.band( face.face_flags, ft.FACE_FLAG_KERNING ) > 0,
		underlinePos= face.underline_position/64
	}, meta )

	font:loadGlyphs( 1, 0xFF )
	return font
end

surface.setFont( M.loadFont( "roboto-regular.ttf" , {size=14} ) )

return M
