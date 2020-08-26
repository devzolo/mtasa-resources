local super = Class("EventMulticaster", LuaObject).getSuperclass()

function EventMulticaster:init(a, b)
	super.init(self)
	self.a = a
	self.b = b
	return self
end

function EventMulticaster.remove(l, oldl)
	return EventMulticaster.removeInternal(l, oldl)
end

function EventMulticaster:removeSelf(oldl)
	if (oldl == self.a) then
		return self.b
	end
	if (oldl == self.b) then 
		return self.a
	end
	local a2 = EventMulticaster.removeInternal(self.a, oldl)
	local b2 = EventMulticaster.removeInternal(self.b, oldl)
	if (a2 == self.a and b2 == self.b) then
		return self;        -- it's not here
	end
	return EventMulticaster.addInternal(a2, b2)
end

function EventMulticaster.add(a, b)
	return EventMulticaster.addInternal(a, b)
end

function EventMulticaster.addInternal(a, b)
	if (not a) then 
		return b
	end
	if (not b) then 
		return a
	end
	return EventMulticaster(a, b)
end

function EventMulticaster.removeInternal(l, oldl)
	if (l == oldl or not l) then
		return nil
	elseif(instanceOf(l,EventMulticaster) ) then
		return l:removeSelf(oldl)
	else 
		return l -- it's not here
	end
end

function EventMulticaster:call(name, e)
    if(self.a[name])then if(self.a.__index) then self.a[name](self.a, e) else self.a[name](e) end end
	if(self.b[name])then if(self.b.__index) then self.b[name](self.b, e) else self.b[name](e) end end
end

function EventMulticaster.getListeners(l, listenerType)
	if (listenerType == nil) then
		outputDebugString("Listener type should not be null")
	end
	local result = {}
	populateListenerTable(result, l, 0, listenerType);
	return result
end

function EventMulticaster.getListenerCount(l, listenerType)
	if (instanceOf(l, EventMulticaster)) then 
		local mc = l
		return EventMulticaster.getListenerCount(mc.a, listenerType) + EventMulticaster.getListenerCount(mc.b, listenerType) 
	else
		return instanceOf(l, listenerType) and 1 or 0
	end
end

function EventMulticaster.populateListenerTable(a, l, index, listenerType) 
	if (instanceOf(l, EventMulticaster)) then 
		local mc = l
		local lhs = EventMulticaster.populateListenerTable(a, mc.a, index, listenerType)
		return EventMulticaster.populateListenerTable(a, mc.b, lhs, listenerType)
	elseif (instanceOf(l, listenerType)) then 
		a[index] = l
		return index + 1
	else 
		return index
	end
end


-- ActionEvent
function EventMulticaster:actionPerformed(e) self:call('actionPerformed', e) end

-- MouseEvent
function EventMulticaster:mousePressed(e) self:call('mousePressed', e) end
function EventMulticaster:mouseReleased(e) self:call('mouseReleased', e) end
function EventMulticaster:mouseClicked(e) self:call('mouseClicked', e) end
function EventMulticaster:mouseExited(e) self:call('mouseExited', e) end
function EventMulticaster:mouseEntered(e) self:call('mouseEntered', e) end
-- MouseMotionEvent
function EventMulticaster:mouseMoved(e) self:call('mouseMoved', e) end
function EventMulticaster:mouseDragged(e) self:call('mouseDragged', e) end
-- InputEvent
function EventMulticaster:keyTyped(e) self:call('keyTyped', e) end
function EventMulticaster:keyPressed(e) self:call('keyPressed', e) end
function EventMulticaster:keyReleased(e) self:call('keyReleased', e) end

function EventMulticaster:focusGained(e) self:call('focusGained', e) end
function EventMulticaster:focusLost(e) self:call('focusLost', e) end

function EventMulticaster:propertyChange(e) self:call('propertyChange', e) end
-- ChangeListener
function EventMulticaster:stateChanged(e) self:call('stateChanged', e) end
function EventMulticaster:itemStateChanged(e) self:call('itemStateChanged', e) end
-- HierarchyEvent
function EventMulticaster:hierarchyChanged(e) self:call('hierarchyChanged', e) end
-- ContainerEvent
function EventMulticaster:componentAdded(e) self:call('componentAdded', e) end
function EventMulticaster:componentRemoved(e) self:call('componentRemoved', e) end
-- AdjustmentEvent
function EventMulticaster:adjustmentValueChanged(e) self:call('adjustmentValueChanged', e) end
