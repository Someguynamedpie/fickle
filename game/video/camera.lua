--[[
Camera modes:
    scroll - Scroll by moving mouse to screen edges/arrow keys.
    track  - Keep the camera centered on an entity

Can be disabled to ignore input for tracking/scrolling.
]]
local M = {
    x = 0,
    y = 0,
    mode = 'scroll',
    active = false,
    target = nil
}

function M.setTarget(tgt)
    M.target = tgt
end
function M.setPaused(paused)
    M.active = not paused
end


local tween = require('tween')
function M.moveTo(x, y)
    tween.create(self, {x = x, y = y}, 'inOutCube')
end
