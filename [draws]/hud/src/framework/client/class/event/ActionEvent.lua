local super = Class("ActionEvent", Event).getSuperclass()

ActionEvent.SHIFT_MASK		= Event.SHIFT_MASK
ActionEvent.CTRL_MASK		= Event.CTRL_MASK
ActionEvent.META_MASK		= Event.META_MASK
ActionEvent.ALT_MASK		= Event.ALT_MASK
ActionEvent.ACTION_FIRST	= 1001
ActionEvent.ACTION_LAST		= 1001
ActionEvent.ACTION_PERFORMED= ACTION_FIRST

function ActionEvent:init(source, id, command, when, modifiers)
	super.init(self, source, id)
	self.actionCommand = command
	self.when = when
	self.modifiers = modifiers
	return self
end

function ActionEvent:getActionCommand()
	return self.actionCommand
end
