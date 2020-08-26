local super = Class("InputEvent", ComponentEvent).getSuperclass()

InputEvent.SHIFT_MASK = Event.SHIFT_MASK
InputEvent.CTRL_MASK = Event.CTRL_MASK
InputEvent.META_MASK = Event.META_MASK
InputEvent.ALT_MASK = Event.ALT_MASK
--InputEvent.ALT_GRAPH_MASK = 1 << 5
--InputEvent.BUTTON1_MASK = 1 << 4
--InputEvent.BUTTON2_MASK = Event.ALT_MASK
--InputEvent.BUTTON3_MASK = Event.META_MASK
--InputEvent.SHIFT_DOWN_MASK = 1 << 6
--InputEvent.CTRL_DOWN_MASK = 1 << 7
--InputEvent.META_DOWN_MASK = 1 << 8
--InputEvent.ALT_DOWN_MASK = 1 << 9
--InputEvent.BUTTON1_DOWN_MASK = 1 << 10
--InputEvent.BUTTON2_DOWN_MASK = 1 << 11
--InputEvent.BUTTON3_DOWN_MASK = 1 << 12
--InputEvent.ALT_GRAPH_DOWN_MASK = 1 << 13
--InputEvent.FIRST_HIGH_BIT = 1 << 14
--InputEvent.JDK_1_3_MODIFIERS = SHIFT_DOWN_MASK - 1
--InputEvent.HIGH_MODIFIERS = ~( FIRST_HIGH_BIT - 1 )

function InputEvent:init(source, id, when, modifiers)
	super.init(self, source, id)
	self.when = when
	self.modifiers = modifiers
	self.canAccessSystemClipboard = true
	return self
end


function InputEvent:canAccessSystemClipboard()
	return self.canAccessSystemClipboard
end

function InputEvent:isShiftDown()

end
function InputEvent:isControlDown() end
function InputEvent:isMetaDown() end
function InputEvent:isAltDown() end
function InputEvent:isAltGraphDown() end
function InputEvent:getWhen()
	return when
end
function InputEvent:getModifiers() end
function InputEvent:getModifiersEx() end

function InputEvent:consume()
	self.consumed = true
end
function InputEvent:isConsumed()
	return self.consumed
end


