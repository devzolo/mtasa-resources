local super = Class("Event", LuaObject).getSuperclass()

function Event:init(source, id)
	super.init(self)
	self.source = source
	self.consumed = false
	self.focusManagerIsDispatching = false
	self.id = id
end

function Event:getID()
	return self.id
end

function Event:setSource(source)
	if(self.source == source) then
		return
	end
	self.source = source
end

function Event:getSource()
	return self.source
end

function Event:consume()
	if(id == KeyEvent.KEY_PRESSED or
		id == KeyEvent.KEY_RELEASED or
		id == MouseEvent.MOUSE_PRESSED or
		id == MouseEvent.MOUSE_RELEASED or
        id == MouseEvent.MOUSE_MOVED or
		id == MouseEvent.MOUSE_DRAGGED or
		id == MouseEvent.MOUSE_ENTERED or
		id == MouseEvent.MOUSE_EXITED or
		id == MouseEvent.MOUSE_WHEEL
		--id == InputMethodEvent.INPUT_METHOD_TEXT_CHANGED or
		--id == InputMethodEvent.CARET_POSITION_CHANGED or
	) then
		self.consumed = true
	else
        -- event type cannot be consumed
	end
end

function Event:isConsumed()
	return self.consumed
end
