local super = Class("IllegalArgumentException", RuntimeException).getSuperclass()

function IllegalArgumentException:init(...)
	super.init(self, ...)
	return self
end
