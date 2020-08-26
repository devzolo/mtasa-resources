local super = Class("ArrayList", LuaObject).getSuperclass()

function ArrayList:init(thetype, isfunc)
	super.init(self)
	self:setCheckType(thetype, isfunc)
	self.table = {}
	return self
end

function ArrayList:checkType( item )
	if self.hasType then
		if self.customCheck then
			local ok, err = pcall(self.func, item)
			if not ok then 
				return false, err
			else
				return err
			end
		elseif type(item) == self.type then
			return true
		else
			if self.type == "element" then
				return isElement(item)
			elseif self.type == "player" then
				return isElement(item) and getElementType(item) == "player"	
			elseif self.type == "vehicle" then
				return isElement(item) and getElementType(item) == "vehicle"
			elseif self.type == "ped" then
				return isElement(item) and getElementType(item) == "ped"
			elseif self.type == "object" then
				return isElement(item) and getElementType(item) == "object"
			end
		end	
		return false
	end
	return true
end

function ArrayList:add(item, index)
	local ok = self:checkType(item)
	if ok then
		if index and index <= self:size() then
			table.insert(self.table, index,  item) 
		else
			return table.insert(self.table, item)
		end
	end
	return ok
end

function ArrayList:addAll(items, index)
	local ok = true
	local amount = 0
	for k, v in pairs(items) do
		if not self:add(v, index) then
			ok = false
			amount = amount + 1
		end
		index = index + 1
	end
	return ok, tostring(amount).."was the wrong type"
end

function ArrayList:clear()
	self.table = {}
end

function ArrayList:setCheckType(thetype, isfunc)
	if thetype and isfunc then
		self.hasType = true
		self.type = nil
		self.customCheck = true
		self.func = thetype
	elseif thetype and type(thetype) == "string" then
		self.hasType = true
		self.type = thetype
	else
		self.hasType = false
		self.type = nil
	end
end

function ArrayList:getCheckType()
	if self.customCheck then
		return true, self.func
	end
	return false, self.type
end

function ArrayList:toTable()
	local tab = {}
	if not self:isEmpty() then
		tab = table.copy(self.table)
	end
	return tab
end

function ArrayList:setTable(items)
	if items then
		self.table = items
	end
end

function ArrayList:clone()
	local tmp = ArrayList(self.type)
	tmp:setTable(self:toTable())
	return tmp
end

function ArrayList:contains(item)
	return table.hasValue(self.table, item)
end

function ArrayList:get(index)
	return self.table[index]
end

function ArrayList:indexOf(item)
	if not self:isEmpty() then
		for k, v in pairs(self.table) do
			if v == item then
				return k
			end
		end
	end
	return -1
end

function ArrayList:isEmpty()
	return self:size() == 0
end

function ArrayList:lastIndexOf(item) 
	local last = -1
	if not self:isEmpty() then
		for k, v in pairs(self.table) do
			if v == item then
				last = k
			end
		end
	end
	return last
end

function ArrayList:remove(item, isindex)
	if isindex then
		--table.remove(self.table, item)
		self.table[item] = nil
	else
		for k, v in pairs(self.table) do
			if v == item then
				--table.remove(self.table, k)
				self.table[k] = nil
			end
		end
	end
end

function ArrayList:removeRange(start, tend)
	if not tend then
		tend = self:size()
	end
	if start == tend then
		self:remove(self:get(start))
	else
		for i = start, tend do
			self:remove(self:get(start)) --the size and index change, so the index stays the same!
		end
	end
end

function ArrayList:set(index, item)
	if self:size() < index or index <= 0 then
		table.insert(self.table, item)
	else
		self.table[index] = item
	end
	return true
end

function ArrayList:size()
	return #self.table
end

function ArrayList:each(index, callback, ...)
	return table.each(self.table, index, callback, ...)
end





