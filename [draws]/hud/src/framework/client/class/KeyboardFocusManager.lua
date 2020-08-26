local super = Class("KeyboardFocusManager", LuaObject, function()
	static.getCurrentKeyboardFocusManager = function()
		return LuaObject.getSingleton(static)
	end
end).getSuperclass()

KeyboardFocusManager.FORWARD_TRAVERSAL = 0
KeyboardFocusManager.BACKWARD_TRAVERSAL = 1

function KeyboardFocusManager:init()
	super.init(self)
	self.focusOwner = nil
	self.defaultPolicy = DefaultFocusTraversalPolicy()
	return self
end

function KeyboardFocusManager:getDefaultFocusTraversalPolicy()
	return self.defaultPolicy
end

function KeyboardFocusManager:getFocusOwner()
	return self.focusOwner
end

function KeyboardFocusManager:setGlobalFocusOwner(newFocusOwner)
	local currentFocusOwner = self:getFocusOwner()
	local temporary, descendant = false, newFocusOwner
	if (currentFocusOwner) then
		self.currentFocusOwnerEvent = FocusEvent(currentFocusOwner, FocusEvent.FOCUS_LOST, temporary, descendant)
		if(currentFocusOwner.processEvent) then
			currentFocusOwner:processEvent(self.currentFocusOwnerEvent)
		end
	end
	if(newFocusOwner) then
		self.newFocusOwnerEvent = FocusEvent(descendant, FocusEvent.FOCUS_GAINED, temporary, currentFocusOwner)
		if(newFocusOwner.processEvent) then
			newFocusOwner:processEvent(self.newFocusOwnerEvent)
		end
	end
	self.focusOwner = newFocusOwner
end

function KeyboardFocusManager:setGlobalFocusOwnerSilent(newFocusOwner)
	self.focusOwner = newFocusOwner
end

function KeyboardFocusManager:focusPreviousComponent(aComponent)
	if (aComponent ~= nil) then
		aComponent:transferFocusBackward()
	end
end

function KeyboardFocusManager:focusNextComponent(aComponent) 
	if (aComponent ~= nil) then
		--aComponent:transferFocus(true)
	end
end

function KeyboardFocusManager:upFocusCycle(aComponent)
	if (aComponent ~= nil) then
		aComponent:transferFocusUpCycle()
	end
end

function KeyboardFocusManager:downFocusCycle(aContainer)
	if (aContainer ~= nil and aContainer.isFocusCycleRoot()) then
		aContainer:transferFocusDownCycle()
	end
end

function KeyboardFocusManager:processKeyEvent(focusedComponent, e)
	if (focusedComponent:getFocusTraversalKeysEnabled()) then
		self:focusNextComponent(focusedComponent)
	end
end

function KeyboardFocusManager:clearGlobalFocusOwner()

end



