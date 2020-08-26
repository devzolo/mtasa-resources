local super = Class("HierarchyEvent", Event).getSuperclass()

HierarchyEvent.HIERARCHY_FIRST = 1400
HierarchyEvent.HIERARCHY_CHANGED = HIERARCHY_FIRST
HierarchyEvent.ANCESTOR_MOVED = 1 + HIERARCHY_FIRST
HierarchyEvent.ANCESTOR_RESIZED = 2 + HIERARCHY_FIRST
HierarchyEvent.HIERARCHY_LAST = ANCESTOR_RESIZED
HierarchyEvent.PARENT_CHANGED = 0x1
HierarchyEvent.DISPLAYABILITY_CHANGED = 0x2
HierarchyEvent.SHOWING_CHANGED = 0x4

function InputEvent:init(source, id, changed, changedParent, changeFlags)
	super.init(self, source, id)
	self.changed = changed
	self.changedParent = changedParent
	self.changeFlags = changeFlags
end

function InputEvent:getComponent()
	return instanceOf(self.source, Component) and self.source or nil
end

function InputEvent:getChanged()
	return self.changed
end

function InputEvent:getChangedParent()
	return self.changedParent
end

function InputEvent:getChangeFlags()
	return self.changeFlags
end