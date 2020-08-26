local super = Class("HashMap", LuaObject).getSuperclass()

function HashMap:init(thetype, isfunc, thetype2, isfunc2)
	super.init(self)
	self:setCheckType(thetype, isfunc, thetype2, isfunc2)
	self.table = {}
	return self
end

function HashMap:setCheckType(thetype, isfunc, thetype2, isfunc2)
	if thetype and isfunc then
		self.hasKeyType = true
		self.keytype = nil
		self.customKeyCheck = true
		self.func = thetype
	elseif thetype and type(thetype) == "string" then
		self.hasKeyType = true
		self.keytype = thetype
	else
		self.hasKeyType = false
		self.keytype = nil
	end
	
	if thetype2 and isfunc then
		self.hasValueType = true
		self.valuetype = nil
		self.customValueCheck = true
		self.valuefunc = thetype2
	elseif thetype2 and type(thetype2) == "string" then
		self.hasValueType = true
		self.valuetype = thetype2
	else
		self.hasValueType = false
		self.valuetype = nil
	end
end


function HashMap:checkKeyType( item )
	if self.hasKeyType then
		if self.customKeyCheck then
			local ok, err = pcall(self.keyfunc, item)
			if not ok then 
				return false, err
			else
				return err
			end
		elseif type(item) == self.keytype then
			return true
		else
			if self.keytype == "element" then
				return isElement(item)
			elseif self.keytype == "player" then
				return isElement(item) and getElementType(item) == "player"	
			elseif self.keytype == "vehicle" then
				return isElement(item) and getElementType(item) == "vehicle"
			elseif self.keytype == "ped" then
				return isElement(item) and getElementType(item) == "ped"
			elseif self.keytype == "object" then
				return isElement(item) and getElementType(item) == "object"
			end
		end	
		return false
	end
	return true
end

function HashMap:checkValueType( item )
	if self.hasValueType then
		if self.customValueCheck then
			local ok, err = pcall(self.valuefunc, item)
			if not ok then 
				return false, err
			else
				return err
			end
		elseif type(item) == self.valuetype then
			return true
		else
			if self.valuetype == "element" then
				return isElement(item)
			elseif self.valuetype == "player" then
				return isElement(item) and getElementType(item) == "player"	
			elseif self.valuetype == "vehicle" then
				return isElement(item) and getElementType(item) == "vehicle"
			elseif self.valuetype == "ped" then
				return isElement(item) and getElementType(item) == "ped"
			elseif self.valuetype == "object" then
				return isElement(item) and getElementType(item) == "object"
			end
		end	
		return false
	end
	return true
end


function HashMap:clear()
	self.table = {}
end

function HashMap:containsValue( item )
	return table.hasValue(self.table, item)
end

function HashMap:containsKey( key )
	return self.table[key]
end

function HashMap:get( index )
	return self.table[index]
end

function HashMap:isEmpty()
	return table.count(self.table) == 0
end

function HashMap:keySet()
	local tmp = {}
	if not self:isEmpty() then
		for k, v in pairs(self.table) do
			table.insert(tmp, k)
		end
	end
	return tmp
end

function HashMap:put( key, item )
	local ok = (self:checkKeyType( key ) and self:checkValueType( item ))
	if ok then
		self.table[key] = item
	end
	return ok
end

function HashMap:putAll( htable )
	local ok = true
	local amount = 0
	for k, v in pairs(htable) do
		if not self:Put(k, v) then
			ok = false
			amount = amount + 1
		end
	end
	return ok, tostring(amount).."was the wrong type"
end

function HashMap:getKeyCheckType()
	if self.customKeyCheck then
		return true, self.keyfunc
	end
	return false, self.keytype
end

function HashMap:getValueCheckType()
	if self.customValueCheck then
		return true, self.valuefunc
	end
	return false, self.valuetype
end

function HashMap:remove( key )
	self.table[key] = nil
end

function HashMap:size()
	return table.count(self.table)
end

function HashMap:values()
	local tmp = {}
	if not self:isEmpty() then
		for k,v in pairs(self.table) do
			table.insert(tmp, v)
		end
	end
	return tmp
end

function HashMap:toTable()
	local tab = {}
	if not self:isEmpty() then
		tab = table.copy(self.table)
	end
	return tab
end
