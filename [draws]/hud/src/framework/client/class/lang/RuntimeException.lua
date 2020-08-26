local super = Class("RuntimeException", Exception).getSuperclass()

function RuntimeException:init(...)
	super.init(self, ...)
	return self
end
