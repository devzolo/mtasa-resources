local super = Class("ChangeEvent", Event).getSuperclass()

function ChangeEvent:init(source)
	super.init(self, source)
	return self
end
