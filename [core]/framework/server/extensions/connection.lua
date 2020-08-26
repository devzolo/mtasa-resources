function Connection:querySync(...)
	local handle = dbQuery(self, ...)
	if(handle) then
		return dbPoll(handle, -1) 
	end
	return false
end