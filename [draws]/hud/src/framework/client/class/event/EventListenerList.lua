local super = Class("EventListenerList", LuaObject, function()
	static.NULL_ARRAY = {}
end).getSuperclass()

function EventListenerList:init()
	super.init(self)
	self.listenerList = EventListenerList.NULL_ARRAY
	return self
end

function EventListenerList:getListenerList()
	return self.listenerList;
end

function EventListenerList:getListeners(t)
	local lList = self.listenerList
	local n = self:getListenerCount(lList, t)
	local result = {}
	local j = 0
	for i = #lList-2, 1, 2 do
		if (lList[i] == t) then
			result[j] = lList[i+1]
			j = j + 1
		end
	end
	return result
end

function EventListenerList:getListenerCount(t)
	if(not t) then
		return #self.listenerList/2
	end
	local lList = self.listenerList
	return self:getListenerArrayCount(lList, t)	
end

function EventListenerList:getListenerArrayCount(list, t)
	local count = 0;
	for i = 1, #list.length, 2 do
		if (t == list[i]) then
			count = count + 1
		end
	end
	return count
end


function EventListenerList:add(t, l)
	if (l==nil) then
		return
	end
	
	--if (not instanceOf(l, t)) then
	--	throw('IllegalArgumentException("Listener " + l + " is not of type " + t)')
	--end
	if (self.listenerList == EventListenerList.NULL_ARRAY) then
		self.listenerList = { t, l }
	else
		local i = #self.listenerList
		local tmp = self.listenerList
		table.insert(tmp, i, t)
		table.insert(tmp, i+1, l)
		self.listenerList = tmp
	end
end

function EventListenerList:remove(t, l)
	if (l==nil) then
		return
	end
	if (not instanceOf(l, t)) then
		throw('IllegalArgumentException("Listener " + l + " is not of type " + t)')
	end

	local index = -1
	for  i = #self.listenerList-2, 1, -2 do
		if ((self.listenerList[i]==t) and (self.listenerList[i+1] == l)) then
			index = i
			break
		end
	end

	if (index ~= -1) then
		local tmp = self.listenerList
		if (index < #tmp) then
			table.remove(tmp, index)
			table.remove(tmp, index+1)
		end
		self.listenerList = (#tmp == 0) and NULL_ARRAY or tmp
	end
end
