local super = Class("FocusEvent", ComponentEvent).getSuperclass()

FocusEvent.FOCUS_FIRST = 1004
FocusEvent.FOCUS_LAST = 1005
FocusEvent.FOCUS_GAINED = FocusEvent.FOCUS_FIRST --Event.GOT_FOCUS
FocusEvent.FOCUS_LOST = 1 + FocusEvent.FOCUS_FIRST --Event.LOST_FOCUS

function FocusEvent:init(source, id, temporary, opposite)
	super.init(self, source, id)
	self.temporary = temporary or false
	self.opposite = opposite or nil
	return self
end

function FocusEvent:isTemporary()
	return self.temporary
end

function FocusEvent:getOppositeComponent()
	if (self.opposite == nil) then
		return nil
	end
	return self.opposite
end

function FocusEvent:paramString()
	local typeStr = "unknown type"
	if(id == FocusEvent.FOCUS_GAINED) then
		typeStr = "FOCUS_GAINED"
	elseif(id == FocusEvent.FOCUS_LOST) then
		typeStr = "FOCUS_LOST"
	end
	
	if(self.temporary) then typeStr = typeStr .. ",temporary" else typeStr = typeStr .. ",permanent" end
	--IIF(temporary,",temporary",",permanent")
    return typeStr .. ",opposite=" .. tostring(self:getOppositeComponent())
end
