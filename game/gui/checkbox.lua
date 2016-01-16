local panel = class( 'gui.Checkbox', 'gui.Label' )
panel.rOffX = 16
panel.rOffY = 2

local scheme = require( 'gui.scheme' )
local tween = require( 'lib.tween' )
function panel:init()
    self.checked = true
    self.col = Color(255,255,255,255)
    self.type = 'checkmark'
    self:setHeight(16)
end
function panel:setCheckmark(type)
    self.type = type and 'checkmark' or 'cross'
end
function panel:draw()
    gui.drawIcon('box', 0, 0, scheme.checkbox.background)
    local percent = self.tween and self.tween() or 1
    local perc = math.floor( percent * 5 )
    local opacity = self:getOpacity()
    surface.setAlphaMultiplierOverride((1-percent)*opacity)
    gui.drawIcon(self.type, -perc, -perc, self.col, perc*2 + 16, perc*2 + 16)
    surface.setAlphaMultiplierOverride(opacity)
    self.baseclass.draw(self)
end
function panel:setChecked(checked)
    self.checked = checked and true or false
    tween.remove( self.tween )
    self.tween = tween.eztween( .2, 'outCubic', nil, not checked )
end
function panel:onmouseup(btn)
    if btn == MOUSE_LEFT then
        self:setChecked(not self.checked)
    end
end
return panel
