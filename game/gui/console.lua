local console = require'console'
local conframe = gui.new('frame')
conframe.CONSOLE = true
conframe:setTitle("Console")
conframe:setSize(500, 500)

function conframe.xbutton:onclick()
    conframe:fadeOut()
end
local rich = gui.new('richtext', conframe)
rich:dock(DOCK_FILL)
local input = gui.new('textbox', conframe)
input:dock(DOCK_BOTTOM)
function input:onenter(txt)
    self:setText('')
    console.print(true, '] ' .. txt)
    io.write('] ' .. txt .. '\n')
    console.execute(txt)
end
function console.toggle()
	
    if conframe:isVisible() and not conframe.fadingOut then
        conframe:fadeOut()
    elseif not conframe.fadingIn then
        conframe:fadeIn()
		gui.setFocus( input )
    end
	conframe:bringToFront()
end
function console.print(nl,...)
    rich:addText(...)
    if nl then
        rich:addText'\n'
    end
end
local logger = require'log'

function console.onlog(category, priority, message)
    rich:addText('[',logger.colors[priority], logger.categories[category], color_white,'] ', color_white, message, '\n')
end
logger.addReceiver(console.onlog)
conframe:makePopup()
conframe:setVisible( false )
return console
