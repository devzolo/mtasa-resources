local super = Class("MouseInfo", LuaObject).getSuperclass()

MouseInfo.x = 0
MouseInfo.y = 0
MouseInfo.component = nil

function MouseInfo:init()
	super.init(self)
end

function MouseInfo.setPointLocation(x, y)
	MouseInfo.x = x
	MouseInfo.y = y
end

function MouseInfo.getPoint()
	return MouseInfo.x, MouseInfo.y
end

function MouseInfo.getOverComponent()
	return MouseInfo.component
end

function MouseInfo.setOverComponent(component)
	MouseInfo.component = component
end


