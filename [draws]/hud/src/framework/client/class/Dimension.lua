local super = Class("Dimension", LuaObject).getSuperclass()

function Dimension:init(...)
	super.init(self)
	self:setSize(...)
	return self
end

function Dimension:getWidth()
	return self.width
end

function Dimension:getHeight()
	return self.height
end

function Dimension:setSize(...)
	if(type(arg[1]) == "table") then
		self.width = arg[1].width or 0
		self.height = arg[1].height or 0
	else
		self.width = math.ceil(arg[1] or 0)
		self.height = math.ceil(arg[2] or 0)
	end
end
  
function Dimension:getSize()
	return Dimension(self.width, self.height)
end
  
function Dimension:equals(obj)
	if (instanceOf(obj,Dimension) ) then
		local pt = obj
		return (self.width == pt.width) and (self.height == pt.height)
	end
	return super.equals(self, obj)
end

function Dimension:hashCode()
	local sum = self.width + self.height
    return sum * (sum + 1)/2 + self.width
end

function Dimension:toString()
	return self.name .. "[width=" .. self.width .. ",height=" .. self.height .. "]"
end
