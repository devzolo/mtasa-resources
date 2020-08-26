local super = Class("ComponentEvent", Event).getSuperclass()

ComponentEvent.COMPONENT_FIRST	= 100
ComponentEvent.COMPONENT_LAST	= 103
ComponentEvent.COMPONENT_MOVED	= ComponentEvent.COMPONENT_FIRST
ComponentEvent.COMPONENT_RESIZED= 1 + ComponentEvent.COMPONENT_FIRST
ComponentEvent.COMPONENT_SHOWN	= 2 + ComponentEvent.COMPONENT_FIRST
ComponentEvent.COMPONENT_HIDDEN	= 3 + ComponentEvent.COMPONENT_FIRST

function ComponentEvent:init(source, id)
	super.init(self, source, id)
	self.data = nil
	self.consumed = false
	self.focusManagerIsDispatching = false
	self.isPosted = false
	return self
end

function ComponentEvent:getComponent()
	if(instanceOf(self.source, Component)) then
		return self.source
	end
	return nil
end

