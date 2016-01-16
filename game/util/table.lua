function table.hasValue( tbl, val )
	for k, v in pairs( tbl ) do
		if( v == val ) then return k end
	end
end
