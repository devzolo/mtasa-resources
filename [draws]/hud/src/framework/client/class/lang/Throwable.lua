local super = Class("Throwable", LuaObject).getSuperclass()

function Throwable:init()
	super.init(self)
	if(isAssignableFrom(arg, {"string"})) then
		local message = unpack(arg)
		self.detailMessage = message
	elseif(isAssignableFrom(arg, {"string", "table"})) then
		local message, cause = unpack(arg)
		self.detailMessage = message
		self.cause = cause
	end
	return self
end

function Throwable:getMessage()
	return self.detailMessage
end

