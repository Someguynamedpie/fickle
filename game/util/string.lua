function string:startsWith( str )
	return self:sub( 1, #str ) == str
end
function string:trim()
	return self:match"^%s*(.-)%s*$"
end
function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end