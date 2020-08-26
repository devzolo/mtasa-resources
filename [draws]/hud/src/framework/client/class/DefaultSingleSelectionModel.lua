local super = Class("DefaultSingleSelectionModel", LuaObject, function()

end).getSuperclass()

function DefaultSingleSelectionModel:init()
	super.init(self)
	self.changeEvent = null;
	self.listenerList = nil
	self.index = -1
	return self
end

function DefaultSingleSelectionModel:getSelectedIndex()
	return self.index
end

function DefaultSingleSelectionModel:setSelectedIndex(index)
	if (self.index ~= index) then
		self.index = index
		self:fireStateChanged()
	end
end

function DefaultSingleSelectionModel:clearSelection()
	self:setSelectedIndex(-1);
end

function DefaultSingleSelectionModel:isSelected()
	local ret = false
	if (self:getSelectedIndex() ~= -1) then
		ret = true
	end
	return ret
end


function DefaultSingleSelectionModel:addChangeListener(l) 
	if (l == nil) then
		return
	end
	self.changeListener = EventMulticaster.add(self.changeListener, l)		
end


function DefaultSingleSelectionModel:removeChangeListener(l)
	if (l == nil) then
		return
	end
	self.changeListener = EventMulticaster.remove(self.changeListener, l)
end


function DefaultSingleSelectionModel:getChangeListeners() 
	return {self.changeListener}
end

function DefaultSingleSelectionModel:fireStateChanged()
	if (changeEvent == nil) then
		changeEvent = ChangeEvent(self)
	end
	self.changeListener:stateChanged(changeEvent)
end

function DefaultSingleSelectionModel:getListeners(listenerType)
	return self.listenerList:getListeners(listenerType)
end


	