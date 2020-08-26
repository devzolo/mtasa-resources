local super = Class("Exception", Throwable).getSuperclass()

function Exception:init(...)
	super.init(self, ...)
	return self
end
