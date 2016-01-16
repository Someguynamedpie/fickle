local mmusic = require'audio'.loadSource'menu.ogg'
--local mmusic = require'audio'.loadSource'BEMainMenuMusic.ogg'
local ambispace = require'audio'.loadSource'robocop.ogg'

--ambispace:setGain(0)
mmusic:play()
ambispace:play()
ambispace:setGain(0)
local system = require'system'

local gui = require'gui'

local root = gui.new( 'panel' )
root:dock( DOCK_FILL )

local icon = Texture( "ss13_64.png" )


local frame = gui.new('frame', root)
frame:setTitle( "SandGOON Menu" )
frame:setSize( 300, 300 )
frame:center()
frame:makePopup()
frame.xbutton:remove()

local newGameMenu = 0

local aboutTxt = gui.new( 'richtext', frame )
aboutTxt:setHeight( 100 )
aboutTxt:dock( DOCK_TOP )
aboutTxt:addText( [[There are words here.]], color_red, " OBEY ALL OF THEM OR DIE" )

local newGameBtn = gui.new( 'button', frame )
newGameBtn:dock( DOCK_TOP )
newGameBtn:setText( "Singleplayer" )

local hostBtn = gui.new( 'button', frame )
hostBtn:dock( DOCK_TOP )
hostBtn:setText( "Host Server..." )
function hostBtn:onclick()
	frame:fadeOut( function()
		mmusic:attachEffect( FadeOutAudioEffect:new( .5 ) )
		root:remove()
		net.host('*')
		require'sandgoon'
		
	end )
end


function newGameBtn:onclick()
	ambispace:attachEffect( FadeInAudioEffect:new( 1 ) )
	mmusic:attachEffect( FadeOutAudioEffect:new( 1 ) )
	frame:fadeOut( )
	newGameMenu = system.getTime() + 1
	
	local menu = gui.new( 'frame', root )
	menu:setSize( 200, 200 )
	menu:setTitle( "Singleplayer" )
	
	local campaignBtn = gui.new( 'button', menu )
	campaignBtn:dock( DOCK_TOP )
	campaignBtn:setText( "New Campaign" )
	
	local loadGameBtn = gui.new( 'button', menu )
	loadGameBtn:dock( DOCK_TOP )
	loadGameBtn:setText( "Load Game" )
	
	local backBtn = gui.new( 'button', menu )
	backBtn:dock( DOCK_TOP )
	backBtn:setText( "Back" )
	
	function menu.xbutton:onclick()
		menu:fadeOut(function()menu:remove()end)
		mmusic:attachEffect( FadeInAudioEffect:new( 1 ) )
		ambispace:attachEffect( FadeOutAudioEffect:new( 1 ) )
		newGameMenu = 0
		frame:fadeIn()
	end
	backBtn.onclick = menu.xbutton.onclick
	menu:center()
	menu:fadeIn()
	
end

local serverBtn = gui.new( 'button', frame )
serverBtn:dock( DOCK_TOP )
serverBtn:setText( "Connect to Server" )
function serverBtn:onclick()
	local sayDialog = gui.new( 'frame', root )
	sayDialog:setTitle( "IP" )
	sayDialog:setSize( 400, 75 )
	sayDialog:center()
	sayDialog:makePopup()
	local entry = gui.new( 'textbox', sayDialog )
	entry:dock( DOCK_TOP )
	gui.setFocus( entry )
	function entry:onenter(msg)
		root:remove()
		mmusic:attachEffect( FadeOutAudioEffect:new( .5 ) )
		require'sandgoon'
		net.connect( msg )
	end
end

local quitBtn = gui.new( 'button', frame )
quitBtn:dock( DOCK_TOP )
quitBtn:setText( "Quit" )
function quitBtn:onclick()
	fickle.exit()
end



function root:draw()
	if not self.inited then
		frame:center()
		self.inited = true
	end
	if newGameMenu == 0 then return end
	surface.setTexture( icon )
	surface.setTextureColor( 255, 255, 255, (1 - math.max( newGameMenu - system.getTime(), 0 ))*128 )
	local delta = (system.getTime() * 32) % 64
	for x = 0, self.w/64 + 1 do
		for y = 0, self.h/64 + 1 do
			surface.drawTexturedRect( x * 64 - delta, y * 64 - delta, 64, 64 )
		end
	end
end
