local super = Class("Checkbox", Component).getSuperclass()

Checkbox.base = "checkbox"
Checkbox.nameCounter = 0


function Checkbox:init(label, state, group)
	super.init(self)
	self.label = label or ""
	self.state = state or false
	self.group = group or nil
	self.labelColor = tocolor(0,0,0,255)
	if (state and (group ~= nil)) then
		group:setSelectedCheckbox(self)
	end
	self:addMouseListener(self)
	return self
end

function Checkbox:constructComponentName() 
	Checkbox.nameCounter = Checkbox.nameCounter + 1
    return Checkbox.base .. Checkbox.nameCounter
end
      
function Checkbox:getLabel()
	return self.label
end  

function Checkbox:setLabel(label)
	local testvalid = false;
	if (self.label == nil or self.label ~= label) then
		self.label = label
		testvalid = true;
	end

	-- This could change the preferred size of the Component.
	if (testvalid) then
		self:invalidateIfValid()
	end
end

function Checkbox:setLabelColor(color)
	self.labelColor = color
end

function Checkbox:getLabelColor()
	return self.labelColor
end

function Checkbox:invalidateIfValid()
	
end

function Checkbox:getState()
	return self.state
end

function Checkbox:setState(state)
	-- Cannot hold check box lock when calling group.setSelectedCheckbox.
	local group = self.group
	if (group ~= nil) then
		if (state) then
			group:setSelectedCheckbox(self)
		elseif (group:getSelectedCheckbox() == self) then
			state = true;
		end
	end
	self:setStateInternal(state)
end

function Checkbox:setStateInternal(state)
	self.state = state
end

function Checkbox:getSelectedObjects()
	if (self.state) then
		return {self.label}
	end
	return nil
end

function Checkbox:getCheckboxGroup()
	return self.group
end

function Checkbox:setCheckboxGroup(g)
	if (self.group == g) then
		return
	end

	local oldGroup = self.group
	local oldState = self:getState()

	self.group = g

	if (self.group ~= nil and self:getState()) then
		if (self.group:getSelectedCheckbox() ~= nil) then
			setState(false);
		else
			self.group:setSelectedCheckbox(self);
		end
	end

	if (oldGroup ~= nil and oldState) then
		oldGroup:setSelectedCheckbox(nil);
	end
end

function Checkbox:addItemListener(l) 
	if (l == nil) then
		return
	end
	self.itemListener = EventMulticaster.add(self.itemListener, l)
	self.newEventsOnly = true;
end

function Checkbox:removeItemListener(l)
	if (l == nil) then
		return
	end
	self.itemListener = EventMulticaster.remove(self.itemListener, l)
end


function Checkbox:processEvent(e)
	if (instanceOf(e,ItemEvent)) then
		self:processItemEvent(e)
		return
	end
	super.processEvent(self, e)
end

function Checkbox:processItemEvent(e)
	local listener = self.itemListener
	if (listener ~= nil)then
		if(listener.__index)then
			listener:itemStateChanged(e) 
		else
			listener.itemStateChanged(e) 
		end		
	end
end

function Checkbox:paint(g)
	local x, y = self:getLocationOnScreen()
	local w = self:getWidth()
	local h = self:getHeight()
	
	g:drawSetColor(self:getBackground())
	g:drawFilledRect(x,   y,   w, 1)
	g:drawFilledRect(x+w, y,   1, h)
	g:drawFilledRect(x,   y,   1, h)
	g:drawFilledRect(x,   y+h, w, 1)
	
	g:drawSetColor(self:getForeground())
	g:drawFilledRect(x + 1, y + 1, w - 1, h - 1)
	
	if(self:getState()) then
		g:drawSetColor(self:getBackground())
		g:drawSetLineWidth(1)
		g:drawLine(x, y, x+w, y+h)
		g:drawLine(x+w, y, x, y+h)
	end
	
	g:drawSetTextScale(1)
	local fh = g:getFontHeight(self.font)
	local px, py = x+w+2, y+(h-fh)/2
	g:drawSetTextFont(self.font)	
	g:drawSetTextPos(px, py)
	g:drawSetTextColor(self.labelColor)
	g:drawPrintText(self.label,0)
end

function Checkbox:mouseClicked(e)
end

function Checkbox:mousePressed(e)
	self:setState(not self:getState())
	self:processEvent(ItemEvent(self, ItemEvent.ITEM_STATE_CHANGED, self, iif(self:getState(),ItemEvent.SELECTED,ItemEvent.DESELECTED)))
end

function Checkbox:mouseReleased(e)
	
end

function Checkbox:mouseEntered(e)

end

function Checkbox:mouseExited(e)

end