local super = Class("KeyEvent", InputEvent).getSuperclass()

KeyEvent.KEY_FIRST = 400
KeyEvent.KEY_LAST = 402
KeyEvent.KEY_TYPED = KeyEvent.KEY_FIRST
KeyEvent.KEY_PRESSED = 1 + KeyEvent.KEY_FIRST
KeyEvent.KEY_RELEASED = 2 + KeyEvent.KEY_FIRST

KeyEvent.VK_ENTER = '\n'
KeyEvent.VK_BACK_SPACE = '\b'
KeyEvent.VK_TAB = '\t'
	

function KeyEvent:init(source, id, when, modifiers, keyCode, keyChar, keyLocation)
	super.init(self, source, id, when, modifiers)
	self.when = when
	self.modifiers = modifiers
	self.keyCode = keyCode
	self.keyChar = keyChar
	self.keyLocation = keyLocation
	self.canAccessSystemClipboard = true
	return self
end


function KeyEvent:canAccessSystemClipboard()
	return self.canAccessSystemClipboard
end

function KeyEvent:isShiftDown()

end
function KeyEvent:isControlDown() end
function KeyEvent:isMetaDown() end
function KeyEvent:isAltDown() end
function KeyEvent:isAltGraphDown() end
function KeyEvent:getWhen()
	return self.when
end
function KeyEvent:getModifiers() end
function KeyEvent:getModifiersEx() end

function KeyEvent:getKeyCode()
	return self.keyCode
end

function KeyEvent:getKeyChar()
	return self.keyChar
end

function KeyEvent:getKeyLocation()
	return self.keyLocation
end

function KeyEvent:consume()
	self.consumed = true
end
function KeyEvent:isConsumed()
	return self.consumed
end


