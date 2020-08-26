local super = Class("Point", LuaObject).getSuperclass()

function Point:init(...)
	super.init(self)
	self:setLocation(...)
	return self
end

function Point:getX()
	return self.x
end

function Point:getY()
	return self.y
end

function Point:getLocation()
	return Point(self.x, self.y)
end

function Point:setLocation(...)
	if(type(arg[1]) == "table") then
		self.x = arg[1].x or 0
		self.y = arg[1].y or 0
	else
		self.x = math.floor((arg[1] or 0)+0.5)
		self.y = math.floor((arg[2] or 0)+0.5)
	end
end
    
function Point:move(x, y)
	self.x = x
	self.y = y
end

function Point:translate(dx, dy)
	self.x = self.x + dx
	self.y = self.y + dy
end

function Point:equals(obj)
	if (instanceOf(obj,Point) ) then
		local pt = obj
		return (self.x == pt.x) and (self.y == pt.y)
	end
	return super.equals(self, obj)
end
