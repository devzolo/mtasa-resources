local super = Class("ItemEvent", Event).getSuperclass()

ItemEvent.ITEM_FIRST = 701
ItemEvent.ITEM_LAST = 701
ItemEvent.ITEM_STATE_CHANGED  = ITEM_FIRST -- Event.LIST_SELECT
ItemEvent.SELECTED = 1
ItemEvent.DESELECTED = 2

function ItemEvent:init(source, id, item, stateChange)
	super.init(self, source, id)
	self.item = item or nil
	self.stateChange = stateChange or 0
	return self
end

function ItemEvent:getItemSelectable()
	return self.source
end

function ItemEvent:getItem()
	return self.item
end

function ItemEvent:getStateChange()
	return self.stateChange
end

function ItemEvent:paramString()
	local typeStr = "unknown type"
	if(id == ItemEvent.ITEM_STATE_CHANGED) then
		typeStr = "ITEM_STATE_CHANGED"
	end
	
	local stateStr = "unknown type"
	if(id == ItemEvent.SELECTED) then
		stateStr = "SELECTED"
	elseif(id == ItemEvent.DESELECTED) then
		stateStr = "DESELECTED"		
	end
	
    return typeStr .. ",item=" .. type(self.item) .. ",stateChange=" .. stateStr
end
