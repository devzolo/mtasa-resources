local super = Class("AbstractBorder", LuaObject).getSuperclass()

function AbstractBorder:init()
	super.init(self)
	return self
end


function AbstractBorder:paintBorder(c, g, x, y, width, height) end

function AbstractBorder:getBorderInsets(c, insets)
	if(insets == nil) then
		insets = Insets(0, 0, 0, 0)
	end
	insets.left = 0
	insets.top = 0
	insets.right = 0
	insets.bottom = 0
    return insets
end

function AbstractBorder:isBorderOpaque(c, insets)
	return false
end

function AbstractBorder:getInteriorRectangle(c, x, y, width, height)
	return self:getInteriorRectangle(c, this, x, y, width, height);
end

function AbstractBorder:getInteriorRectangle(...)
	local c = arg[1]
	local b
	local x
	local y 
	local width 
	local height
	local insets
	
	if(instanceOf(arg[2], AbstractBorder)) then
		b = arg[2]
		x = arg[3]
		y = arg[4]
		width = arg[5] 
		height = arg[6]	
	else
		b = self
		x = arg[2]
		y = arg[3]
		width = arg[4] 
		height = arg[5]	
	end


	if(b ~= nil) then
		insets = b.getBorderInsets(c)
	else
		insets = Insets(0, 0, 0, 0);
	end
	return Rectangle(x + insets.left, y + insets.top, width - insets.right - insets.left, height - insets.top - insets.bottom);
end

function AbstractBorder:getBaseline(c, width, height)
	if (width < 0 or height < 0) then
		error("Width and height must be >= 0")
	end
	return -1;
end

function AbstractBorder:getBaselineResizeBehavior(c) 
	if (c == nil) then
		error("Component must be non-null")
	end
	return Component.BaselineResizeBehavior.OTHER
end

function AbstractBorder.isLeftToRight(c)
    return c.getComponentOrientation().isLeftToRight()
end
