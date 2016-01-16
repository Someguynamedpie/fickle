--audio.open( "music/menu.ogg", "stream" )
--music.setQueue{ "music/menu.ogg" }
local M = {
	activeQueue = {},
	order = 'sequential',
	next = 0
}
function M.nextSong()
	if M.order == 'sequential' then
		M.next = M.next + 1
		if( M.next > #M.activeQueue ) then
			M.next = 1
		end
	elseif M.order == 'random' then
		local nxt = math.random( 1, #M.activeQueue )
		while nxt ~= M.next and #M.activeQueue > 1 do nxt = math.random( 1, #M.activeQueue ) end
	end
	M.activeQueue[ M.next ]:play()
	M.activeSong = M.activeQueue[ M.next ]
	M.activeQueue[ M.next ]:attachEffect( FadeOutAudioEffect:new( math.min(M.activeSong:getDuration(), 5), M.nextSong, math.max(M.activeSong:getDuration() - 5, 0) ) )
	M.activeQueue[ M.next ]:attachEffect( FadeInAudioEffect:new( math.min(M.activeSong:getDuration(), 2) ) )
	
end
function M.setQueue(newQueue, order)
	M.activeQueue = newQueue
	M.order = order or 'sequential'
	M.next = 0
	if M.activeSong then
		M.activeSong:clearEffects()
		M.activeSong:attachEffect( FadeOutAudioEffect:new( math.min(M.activeSong:getDuration() - M.activeSong:getOffset(), 0.5), M.nextSong ) )
	else
		M.nextSong()
	end
end
return M