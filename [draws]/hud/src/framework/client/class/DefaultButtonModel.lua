local super = Class("DefaultButtonModel", LuaObject).getSuperclass()

DefaultButtonModel.ARMED = bitLShift(1,0)
DefaultButtonModel.SELECTED = bitLShift(1,1)
DefaultButtonModel.PRESSED = bitLShift(1,2)
DefaultButtonModel.ENABLED = bitLShift(1,3)
DefaultButtonModel.ROLLOVER = bitLShift(1,4)

function DefaultButtonModel:init(...)
	super.init(self)
	local args = {...}
	self.stateMask = 0
    self.actionCommand = nil
	self.group = nil
    self.mnemonic = 0
	self.changeEvent = nil;
	self.changeListener = nil
	self.actionListener = nil
	self.itemListener = nil
	self.menuItem = false
	self:setEnabled(true)
	self:setSource(args[1])
	return self
end

function DefaultButtonModel:setSource(src)
	self.source = src
end

function DefaultButtonModel:getSource()
	return self.source
end

function DefaultButtonModel:isArmed() 
	return bitAnd(self.stateMask, DefaultButtonModel.ARMED) ~= 0
end

function DefaultButtonModel:isSelected() 
	return bitAnd(self.stateMask, DefaultButtonModel.SELECTED) ~= 0
end

function DefaultButtonModel:isEnabled() 
	return bitAnd(self.stateMask, DefaultButtonModel.ENABLED) ~= 0
end

function DefaultButtonModel:isPressed()
	return bitAnd(self.stateMask, DefaultButtonModel.PRESSED) ~= 0
end

function DefaultButtonModel:isRollover() 
	return bitAnd(self.stateMask, DefaultButtonModel.ROLLOVER) ~= 0
end

function DefaultButtonModel:setArmed(b) 
	if(self:isMenuItem() and UIManager.getBoolean("MenuItem.disabledAreNavigable")) then
		if (self:isArmed() == b) then
			return
		end
	else
		if (self:isArmed() == b or not self:isEnabled()) then
			return
		end
	end

	if (b) then
		self.stateMask = bitOr(self.stateMask, DefaultButtonModel.ARMED)
	else
		self.stateMask = bitXor(self.stateMask, DefaultButtonModel.ARMED)
	end

	self:fireStateChanged()
end

function DefaultButtonModel:setEnabled(b) 
	if(self:isEnabled() == b) then
		return
	end

	if (b) then
		self.stateMask = bitOr(self.stateMask, DefaultButtonModel.ENABLED)
	else 
		self.stateMask = bitXor(self.stateMask, DefaultButtonModel.ENABLED)
		-- unarm and unpress, just in case
		self.stateMask = bitXor(self.stateMask, DefaultButtonModel.ARMED)
		self.stateMask = bitXor(self.stateMask, DefaultButtonModel.PRESSED)
	end

	self:fireStateChanged();
end

function DefaultButtonModel:setSelected(b) 
    if (self:isSelected() == b) then
		return
	end

	if (b) then
		self.stateMask = bitOr(self.stateMask, DefaultButtonModel.SELECTED)
	else
		self.stateMask = bitXor(self.stateMask, DefaultButtonModel.SELECTED)
	end

	self:fireItemStateChanged(ItemEvent(self, ItemEvent.ITEM_STATE_CHANGED, self, iif(b, ItemEvent.SELECTED, ItemEvent.DESELECTED)))

	self:fireStateChanged()
end

function DefaultButtonModel:setPressed(b)
	
	if((self:isPressed() == b) or not self:isEnabled()) then
		return
	end
	
	if (b) then
		self.stateMask = bitOr(self.stateMask, DefaultButtonModel.PRESSED)
	else
		self.stateMask = bitXor(self.stateMask, DefaultButtonModel.PRESSED)
	end

	if(not self:isPressed() and self:isArmed()) then
		local modifiers = 0
		--local currentEvent = EventQueue.getCurrentEvent()
		--if (instanceOf(currentEvent, InputEvent)) then
		--	modifiers = currentEvent.getModifiers()
		--elseif (instanceOf(currentEvent, ActionEvent)) then
		--	modifiers = currentEvent.getModifiers()
		--end
		self:fireActionPerformed(ActionEvent(self:getSource(),ActionEvent.ACTION_PERFORMED, self:getActionCommand(),0,0))
		--self:fireActionPerformed(ActionEvent(self, ActionEvent.ACTION_PERFORMED, self:getActionCommand(), EventQueue.getMostRecentEventTime(), modifiers));
	end

	self:fireStateChanged()	
end

function DefaultButtonModel:setRollover(b) 
	if(self:isRollover() == b or not self:isEnabled()) then
		return
	end

	if (b) then
		self.stateMask = bitOr(self.stateMask, DefaultButtonModel.ROLLOVER)
	else
		self.stateMask = bitXor(self.stateMask, DefaultButtonModel.ROLLOVER)
	end

	self:fireStateChanged();
end

function DefaultButtonModel:setMnemonic(key) 
	self.mnemonic = key
	self:fireStateChanged()
end

function DefaultButtonModel:getMnemonic() 
	return self.mnemonic;
end

function DefaultButtonModel:setActionCommand(s) 
	self.actionCommand = s	
end

function DefaultButtonModel:getActionCommand() 
	return self.actionCommand
end

function DefaultButtonModel:addActionListener(l) 
	if (l == nil) then
		return
	end
	self.actionListener = EventMulticaster.add(self.actionListener, l)	
end

function DefaultButtonModel:removeActionListener(l) 
	if (l == nil) then
		return
	end
	self.actionListener = EventMulticaster.remove(self.actionListener, l)	
end

function DefaultButtonModel:getActionListeners()
	return {self.actionListener}
end

function DefaultButtonModel:addItemListener(l) 
	if (l == nil) then
		return
	end
	self.itemListener = EventMulticaster.add(self.itemListener, l)	
end

function DefaultButtonModel:removeItemListener(l) 
	if (l == nil) then
		return
	end
	self.itemListener = EventMulticaster.remove(self.itemListener, l)	
end

function DefaultButtonModel:getItemListeners()
	return {self.itemListener}
end

function DefaultButtonModel:addChangeListener(l) 
	if (l == nil) then
		return
	end
	self.changeListener = EventMulticaster.add(self.changeListener, l)	
end

function DefaultButtonModel:removeChangeListener(l) 
	if (l == nil) then
		return
	end
	self.changeListener = EventMulticaster.remove(self.changeListener, l)	
end

function DefaultButtonModel:fireItemStateChanged(e)
	if(self.itemListener) then
		self.itemListener:itemStateChanged(e)
	end
end
	
function DefaultButtonModel:getListeners(listenerType)
	return self.listenerList:getListeners(listenerType)
end

function DefaultButtonModel:getSelectedObjects()
	return nil
end

function DefaultButtonModel:getGroup()
	return self.group
end
	
function DefaultButtonModel:setGroup(group) 
	self.group = group
end

function DefaultButtonModel:isMenuItem()
	return self.menuItem;
end

function DefaultButtonModel:setMenuItem(menuItem)
	self.menuItem = menuItem;
end

function DefaultButtonModel:fireStateChanged(e)
	if (self.changeListener) then
        if(self.changeEvent == nil) then
			self.changeEvent = ChangeEvent(self)
		end
		self.changeListener:stateChanged(self.changeEvent)
	end
end

function DefaultButtonModel:fireActionPerformed(e)
	if (self.actionListener) then
		self.actionListener:actionPerformed(e)
	end
end