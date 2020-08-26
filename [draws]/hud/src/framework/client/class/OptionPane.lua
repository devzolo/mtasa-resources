local super = Class("OptionPane", Component, function()
	-- Option types
	static.DEFAULT_OPTION = -1
	static.YES_NO_OPTION = 0
	static.YES_NO_CANCEL_OPTION = 1
	static.OK_CANCEL_OPTION = 2

	-- Return values.
	static.YES_OPTION = 0
	static.NO_OPTION = 1
	static.CANCEL_OPTION = 2
	static.OK_OPTION = 0
	static.CLOSED_OPTION = -1

	-- Used for error messages.
	static.ERROR_MESSAGE = 0
	static.INFORMATION_MESSAGE = 1
	static.WARNING_MESSAGE = 2
	static.QUESTION_MESSAGE = 3
	static.PLAIN_MESSAGE = -1
	
	
    static.ICON_PROPERTY = "icon"
    static.MESSAGE_PROPERTY = "message"
    static.VALUE_PROPERTY = "value"
    static.OPTIONS_PROPERTY = "options"
    static.INITIAL_VALUE_PROPERTY = "initialValue"
    static.MESSAGE_TYPE_PROPERTY = "messageType"
    static.OPTION_TYPE_PROPERTY = "optionType"
    static.SELECTION_VALUES_PROPERTY = "selectionValues"
    static.INITIAL_SELECTION_VALUE_PROPERTY = "initialSelectionValue"
    static.INPUT_VALUE_PROPERTY = "inputValue"
    static.WANTS_INPUT_PROPERTY = "wantsInput"
end).getSuperclass()


function OptionPane:init(message, messageType, optionType, icon, options, initialValue)
	super.init(self)
    self.icon = icon
    self.message = message
    self.options = options
    self.initialValue = initialValue
	self:setMessageType(messageType)
	self:setOptionType(optionType)
	return self
end

function OptionPane:setMessageType(newType)
	if(newType ~= OptionPane.ERROR_MESSAGE and newType ~= OptionPane.INFORMATION_MESSAGE and
	   newType ~= OptionPane.WARNING_MESSAGE and newType ~= OptionPane.QUESTION_MESSAGE and
	   newType ~= OptionPane.PLAIN_MESSAGE) then
		outputDebugString("OptionPane: type must be one of OptionPane.ERROR_MESSAGE, OptionPane.INFORMATION_MESSAGE, OptionPane.WARNING_MESSAGE, OptionPane.QUESTION_MESSAGE or OptionPane.PLAIN_MESSAGE")
	end
	local oldType = self.messageType
	self.messageType = newType
	self:firePropertyChange("messageType", oldType, self.messageType)
end

function OptionPane:getMessageType()
	return self.messageType
end

function OptionPane:setOptionType(newType)
	if(newType ~= OptionPane.DEFAULT_OPTION and newType ~= OptionPane.YES_NO_OPTION and
	   newType ~= OptionPane.YES_NO_CANCEL_OPTION and newType ~= OptionPane.OK_CANCEL_OPTION) then
		outputDebugString("OptionPane: option type must be one of OptionPane.DEFAULT_OPTION, OptionPane.YES_NO_OPTION, OptionPane.YES_NO_CANCEL_OPTION or OptionPane.OK_CANCEL_OPTION")
	end
	local oldType = self.optionType
	self.optionType = newType
	self:firePropertyChange("optionType", oldType, self.optionType)
end

function OptionPane:getOptionType()
	return self.optionType;
end

function OptionPane:setInitialValue(newInitialValue)
	local oldIV = self.initialValue
	self.initialValue = newInitialValue
	self:firePropertyChange("initialValue", oldIV, self.initialValue)
end

function OptionPane:getInitialValue()
	return self.initialValue
end

function OptionPane.styleFromMessageType(messageType)
	if(messageType == OptionPane.ERROR_MESSAGE) then
		return RootPane.ERROR_DIALOG
	elseif(messageType == OptionPane.QUESTION_MESSAGE) then
		return RootPane.QUESTION_DIALOG;
	elseif(messageType == OptionPane.WARNING_MESSAGE) then
		return RootPane.WARNING_DIALOG;
	elseif(messageType == OptionPane.INFORMATION_MESSAGE) then
		return RootPane.INFORMATION_DIALOG;
	else -- OptionPane.PLAIN_MESSAGE...
		return RootPane.PLAIN_DIALOG
	end
end

function OptionPane:createDialog(parentComponent, title, style)
	local dialog = nil
	local window = OptionPane.getWindowForComponent(parentComponent)
	dialog = Dialog(window, title, true)
	--[[
	if (window instanceof SwingUtilities.SharedOwnerFrame) {
		WindowListener ownerShutdownListener =
				SwingUtilities.getSharedOwnerFrameShutdownListener();
		dialog.addWindowListener(ownerShutdownListener);
	}
	
	]]
	self:initDialog(dialog, style, parentComponent)
	return dialog
end

function OptionPane:initDialog(dialog, style, parentComponent)
	--dialog:setComponentOrientation(self:getComponentOrientation())
	--local contentPane = dialog:getContentPane()

	--[[
	contentPane:setLayout(BorderLayout()())
	contentPane:add(self, BorderLayout.CENTER)
	dialog:setResizable(false)
	dialog:pack()
	dialog:setLocationRelativeTo(parentComponent)

	OptionPane.self = self
	
	local listener = {
		propertyChange = function(event)
			-- Let the defaultCloseOperation handle the closing
			-- if the user closed the window without selecting a button
			-- (newValue = null in that case).  Otherwise, close the dialog.
			if (dialog:isVisible() and event:getSource() == OptionPane.self and
					event:getPropertyName() == "value" and
					event:getNewValue() ~= nil and
					event:getNewValue() ~= OptionPane.UNINITIALIZED_VALUE) then
				dialog:setVisible(false)
			end
		end
	}

	local adapter = {
		gotFocus = false,
		windowClosing = function(we) 
			self:setValue(nil)
		end,

		windowClosed = function(e)
			self:removePropertyChangeListener(listener)
			dialog:getContentPane():removeAll()
		end,

		windowGainedFocus = function(we)
			-- Once window gets focus, set initial focus
			if (not gotFocus) then
				self:selectInitialValue()
				gotFocus = true
			end
		end,
	}
	
	dialog:addWindowListener(adapter)
	dialog:addWindowFocusListener(adapter)
	dialog:addComponentListener({
		componentShown = function(ce)
			-- reset value to ensure closing works properly
			self:setValue(OptionPane.UNINITIALIZED_VALUE)
		end
	});

	self:addPropertyChangeListener(listener)
	]]
end

function OptionPane.getWindowForComponent(parentComponent)
	if (parentComponent == nil) then
		return OptionPane.getRootFrame()
	end
	if(instanceOf(parentComponent, Frame) or instanceOf(parentComponent, Dialog)) then
		return parentComponent
	end
	return OptionPane.getWindowForComponent(parentComponent:getParent())
end

function OptionPane.getRootFrame()
	return Graphics.getInstance()
end

function OptionPane.showInputDialog(...)
	return OptionPane.showInputDialogImpl(...)
end
	
function OptionPane.showInputDialogImpl(parentComponent, message, title, messageType, icon, selectionValues, initialSelectionValue)

	local pane = OptionPane(message, messageType, OptionPane.OK_CANCEL_OPTION, icon, nil, nil);

	pane.setWantsInput(true)
	pane.setSelectionValues(selectionValues)
	pane.setInitialSelectionValue(initialSelectionValue)
	pane.setComponentOrientation((parentComponent or self:getRootFrame()):getComponentOrientation())

	local style = OptionPane.styleFromMessageType(messageType)
	local dialog = pane:createDialog(parentComponent, title, style)

	pane:selectInitialValue()
	dialog:show()
	dialog:dispose()

	local value = pane:getInputValue()

	if (value == OptionPane.UNINITIALIZED_VALUE) then
		return nil
	end
	return value
end

function OptionPane.showMessageDialog(parentComponent, message, title, messageType, icon)
	OptionPane.showOptionDialog(parentComponent, message, title, OptionPane.DEFAULT_OPTION, messageType, icon, nil, nil)
end

function OptionPane.showOptionDialog(parentComponent, message, title, optionType, messageType, icon, options, initialValue)
	local pane = OptionPane(message, messageType, optionType, icon, options, initialValue)
	pane:setInitialValue(initialValue);
	--pane:setComponentOrientation((parentComponent == nil and self:getRootFrame() or parentComponent):getComponentOrientation())

	local style = OptionPane.styleFromMessageType(messageType)
    local dialog = pane:createDialog(parentComponent, title, style)

	--[[
	pane:selectInitialValue()
	dialog:show()
	dialog:dispose()

	local selectedValue = pane:getValue()

	if(selectedValue == nil) then
		return OptionPane.CLOSED_OPTION
	end
	if(options == nil) then
		if(selectedValue instanceof Integer)
			return ((Integer)selectedValue).intValue();
		return OptionPane.CLOSED_OPTION;
	end
	
	for(int counter = 0, maxCounter = options.length; counter < maxCounter; counter++) {
		if(options[counter].equals(selectedValue))
			return counter;
	}
	]]
	return OptionPane.CLOSED_OPTION;
end