local overlay = ...
local start = os.time() + 5
function overlay:paint()
	if start and os.time() > start then
		start = nil
		local options = {
		"imdb", "zaba", "us census", "united nations", "wikipedia", "telephony", "department of defense", "social networking"
		}
		local start = os.time()
		local tween = require("lib.tween")
		local DUR = 5
		local assimilator = gui.new("panel", overlay)
		local assimilation = tween.eztween( DUR, 'inOutSine', function()
			assimilator:fadeOut(function()
				assimilator:remove()
				loadfile("game/samaritan/target.lua")(overlay)
			end)
		end )

		assimilator:setSize( 200, 100 )
		assimilator:center()
		assimilator:fadeIn()
		
		function assimilator:draw(w,h)
			surface.setTextColor(0,0,0)
			surface.drawText( "TOTAL ACCESS ACHIEVED", 1, 0 )
			surface.setDrawColor(0,0,0)
			surface.fillRect(0,20,200,30)
			surface.setTextColor(255,255,255)
			surface.drawText( "ASSIMILATING DATA", 1, 20 )
			surface.setTextColor(200, 200, 200)
			surface.drawText( options[math.ceil(assimilation() * #options)] or "???", 1, 34 )
			surface.setDrawColor(0,0,0,40)
			surface.fillRect(0, 55,200,10)
			surface.setDrawColor(200,20,20,200)
			surface.fillRect(3,58,assimilation() * 194,4)
		end
		--[[
		TOTAL ACCESS ACHIEVED
		ASSIMILATING DATA
		imdb/zaba/us census/united nations/
		[===                ]

		]]
		end
end