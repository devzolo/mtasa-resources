local super = Class("MouseEvent", InputEvent).getSuperclass()

MouseEvent.MOUSE_FIRST = 500
MouseEvent.MOUSE_LAST = 507
MouseEvent.MOUSE_CLICKED = MouseEvent.MOUSE_FIRST
MouseEvent.MOUSE_PRESSED = 1 + MouseEvent.MOUSE_FIRST --Event.MOUSE_DOWN
MouseEvent.MOUSE_RELEASED = 2 + MouseEvent.MOUSE_FIRST --Event.MOUSE_UP
MouseEvent.MOUSE_MOVED = 3 + MouseEvent.MOUSE_FIRST --Event.MOUSE_MOVE
MouseEvent.MOUSE_ENTERED = 4 + MouseEvent.MOUSE_FIRST --Event.MOUSE_ENTER
MouseEvent.MOUSE_EXITED = 5 + MouseEvent.MOUSE_FIRST --Event.MOUSE_EXIT
MouseEvent.MOUSE_DRAGGED = 6 + MouseEvent.MOUSE_FIRST --Event.MOUSE_DRAG
MouseEvent.MOUSE_WHEEL = 7 + MouseEvent.MOUSE_FIRST
MouseEvent.NOBUTTON = 0
MouseEvent.BUTTON1 = 1
MouseEvent.BUTTON2 = 2
MouseEvent.BUTTON3 = 3

local scrollAmountFromButton = {
	["mouse_wheel_up"] = 1,
	["mouse_wheel_down"] = -1
}

function MouseEvent:init(source, id, when, modifiers, x, y, xAbs, yAbs, clickCount, popupTrigger, button)
	super.init(self, source, id, when, modifiers)
	
	self.x = x
	self.y = y
	self.xAbs = xAbs
	self.yAbs = yAbs
	self.clickCount = clickCount
	self.button = button
	self.popupTrigger = popupTrigger
	self.scrollAmount = scrollAmountFromButton[button] or 0
	
	return self
end

function MouseEvent:getLocationOnScreen()
	return self.xAbs, self.yAbs
end

function MouseEvent:getXOnScreen()
    return self.xAbs
end

function MouseEvent:getYOnScreen()
    return self.yAbs
end

function MouseEvent:getX()
    return self.x
end

function MouseEvent:getY()
    return self.y
end

function MouseEvent:getPoint()
    return self.x, self.y
end

function MouseEvent:getLocation()
	local x, y = self.source:getLocationOnScreen()
	x = self:getXOnScreen() - x
	y = self:getYOnScreen() - y
    return x, y
end

function MouseEvent:translatePoint(x, y)
	self.x = self.x + x
    self.y = self.y + y
end

function MouseEvent:getClickCount()
    return self.clickCount
end

function MouseEvent:getButton()
	return self.button
end

function MouseEvent:isPopupTrigger()
    return self.popupTrigger
end

function MouseEvent:getScrollAmount()
    return self.scrollAmount
end


