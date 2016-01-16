function ents.addToSnapshot( ent )
	table.insert( ents.activeSnapshot, ent )
end

function ents.transmitSnapshot()
	for i, ply in pairs(ents.getPlayers()) do
		local built = {}
		for ei, ent in pairs( ents.getEntities() ) do
			if( ent.networked and ent.dtUpdate and ply:canSee( ent ) ) then
				table.insert( built, ent )
			end
		end
		local snapshot = net.newPacket( "S2C_EntSnapshot" )
		for i = 1, #built do
			snapshot
				