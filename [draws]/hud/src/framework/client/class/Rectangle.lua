local super = Class("Rectangle", LuaObject).getSuperclass()

Rectangle.OUT_LEFT = 1
Rectangle.OUT_TOP = 2
Rectangle.OUT_RIGHT = 4
Rectangle.OUT_BOTTOM = 8

function Rectangle.clip(v, doceil)
	if (v <= Integer.MIN_VALUE) then
		return Integer.MIN_VALUE
	end
	if (v >= Integer.MAX_VALUE) then
		return Integer.MAX_VALUE
	end
	return doceil and math.ceil(v) or math.floor(v)
end

function Rectangle:init(...)
	super.init(self)
	self:setBounds(...)
	return self
end

function Rectangle:getX()
	return self.x
end

function Rectangle:getY()
	return self.y
end

function Rectangle:getWidth()
	return self.width
end

function Rectangle:getHeight()
	return self.height
end

function Rectangle:getBounds()
	return Rectangle(self.x, self.y, self.width, self.height)
end

function Rectangle:setBounds(...)
	if(type(arg[1]) == "table") then
		self.x = arg[1].x or 0
		self.y = arg[1].y or 0
		self.width = arg[1].width or 0
		self.height = arg[1].height or 0
	else
		self.x = math.floor((arg[1] or 0)+0.5)
		self.y = math.floor((arg[2] or 0)+0.5)	
		self.width = math.ceil(arg[3] or 0)
		self.height = math.ceil(arg[4] or 0)
	end
end

function Rectangle:reshape(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
end

function Rectangle:getLocation()
	return Point(self.x, self.y)
end

function Rectangle:setLocation(...)
	if(type(arg[1]) == "table") then
		self.x = arg[1].x or 0
		self.y = arg[1].y or 0
	else
		self.x = math.floor((arg[1] or 0)+0.5)
		self.y = math.floor((arg[2] or 0)+0.5)
	end
end
    
function Rectangle:setSize(...)
	if(type(arg[1]) == "table") then
		self.width = arg[1].width or 0
		self.height = arg[1].height or 0
	else
		self.width = math.ceil(arg[1] or 0)
		self.height = math.ceil(arg[2] or 0)
	end
end
  
function Rectangle:getSize()
	return Dimension(self.width, self.height)
end
	
function Rectangle:move(x, y)
	self.x = x
	self.y = y
end

function Rectangle:translate(dx, dy)
	self.x = self.x + dx
	self.y = self.y + dy
end

function Rectangle:translate(dx, dy)
	local oldv = self.x
	local newv = oldv + dx
	if (dx < 0) then
		-- moving leftward
		if (newv > oldv) then
			-- negative overflow
			-- Only adjust width if it was valid (>= 0).
			if (width >= 0) then
				-- The right edge is now conceptually at
				-- newv+width, but we may move newv to prevent
				-- overflow.  But we want the right edge to
				-- remain at its new location in spite of the
				-- clipping.  Think of the following adjustment
				-- conceptually the same as:
				-- width += newv; newv = MIN_VALUE; width -= newv;
				width = width + newv - Integer.MIN_VALUE
				-- width may go negative if the right edge went past
				-- MIN_VALUE, but it cannot overflow since it cannot
				-- have moved more than MIN_VALUE and any non-negative
				-- number + MIN_VALUE does not overflow.
			end
			newv = Integer.MIN_VALUE
		end
	else
		-- moving rightward (or staying still)
		if (newv < oldv) then
			-- positive overflow
			if (width >= 0) then
				-- Conceptually the same as:
				-- width += newv; newv = MAX_VALUE; width -= newv;
				width = width + newv - Integer.MAX_VALUE
				-- With large widths and large displacements
				-- we may overflow so we need to check it.
				if (width < 0) then width = Integer.MAX_VALUE end
			end
			newv = Integer.MAX_VALUE;
		end
	end
	self.x = newv

	oldv = self.y
	newv = oldv + dy
	if (dy < 0) then
		-- moving upward
		if (newv > oldv) then
			-- negative overflow
			if (height >= 0) then
				height = height + newv - Integer.MIN_VALUE
				-- See above comment about no overflow in this case
			end
			newv = Integer.MIN_VALUE
		end
	else
		-- moving downward (or staying still)
		if (newv < oldv) then
			-- positive overflow
			if (height >= 0) then
				height = height + newv - Integer.MAX_VALUE;
				if (height < 0) then height = Integer.MAX_VALUE end
			end
			newv = Integer.MAX_VALUE;
		end
	end
	self.y = newv
end

function Rectangle:contains(X, Y, W, H)
	local w = self.width
	local h = self.height
	if (w < 0 or h < 0 or W < 0 or H < 0) then
		-- At least one of the dimensions is negative...
		return false
	end
	-- Note: if any dimension is zero, tests below must return false...
	local x = self.x
	local y = self.y
	if (X < x or Y < y) then
		return false
	end
	w = w + x
	W = (W or 0) + X
	if (W <= X) then
		-- X+W overflowed or W was zero, return false if...
		-- either original w or W was zero or
		-- x+w did not overflow or
		-- the overflowed x+w is smaller than the overflowed X+W
		if (w >= x or W > w) then return false end
	else
		-- X+W did not overflow and W was not zero, return false if...
		-- original w was zero or
		-- x+w did not overflow and x+w is smaller than X+W
		if (w >= x and W > w) then return false end
	end
	h = h + y
	H = (H or 0) + Y
	if (H <= Y) then
		if (h >= y or H > h) then return false end
	else 
		if (h >= y and H > h) then return false end
	end
	return true
end

function Rectangle:intersects(r)
	local tw = self.width
	local th = self.height
	local rw = r.width
	local rh = r.height
	if (rw <= 0 or rh <= 0 or tw <= 0 or th <= 0) then
		return false
	end
	local tx = self.x
	local ty = self.y
	local rx = r.x
	local ry = r.y
	rw = rw + rx
	rh = rh + ry
	tw = tw + tx
	th = th + ty
	--      overflow or intersect
	return ((rw < rx or rw > tx) and
			(rh < ry or rh > ty) and
			(tw < tx or tw > rx) and
			(th < ty or th > ry))
end

function Rectangle:intersection(r)
	local tx1 = self.x
	local ty1 = self.y
	local rx1 = r.x
	local ry1 = r.y
	local tx2 = tx1
	tx2 = tx2 + self.width
	local ty2 = ty1
	ty2 = ty2 + self.height
	local rx2 = rx1
	rx2 = rx2 + r.width
	local ry2 = ry1
	ry2 = ry2 + r.height
	if (tx1 < rx1) then tx1 = rx1 end
	if (ty1 < ry1) then ty1 = ry1 end
	if (tx2 > rx2) then tx2 = rx2 end
	if (ty2 > ry2) then ty2 = ry2 end
	tx2 = tx2 - tx1;
	ty2 = ty2 - ty1;
	-- tx2,ty2 will never overflow (they will never be
	-- larger than the smallest of the two source w,h)
	-- they might underflow, though...
	if (tx2 < Integer.MIN_VALUE) then tx2 = Integer.MIN_VALUE end
	if (ty2 < Integer.MIN_VALUE) then ty2 = Integer.MIN_VALUE end
	return Rectangle(tx1, ty1, tx2, ty2)
end

function Rectangle:union(r)
	local tx2 = self.width;
	local ty2 = self.height;
	if (tx2 < 0 or ty2 < 0) then
		-- This rectangle has negative dimensions...
		-- If r has non-negative dimensions then it is the answer.
		-- If r is non-existant (has a negative dimension), then both
		-- are non-existant and we can return any non-existant rectangle
		-- as an answer.  Thus, returning r meets that criterion.
		-- Either way, r is our answer.
		return Rectangle(r)
	end
	local rx2 = r.width
	local ry2 = r.height
	if (rx2 < 0 or ry2 < 0) then
		return Rectangle(self)
	end
	local tx1 = self.x
	local ty1 = self.y
	tx2 = tx2 + tx1
	ty2 = ty2 + ty1
	local rx1 = r.x
	local ry1 = r.y
	rx2 = rx2 + rx1
	ry2 = ry2 + ry1
	if (tx1 > rx1) then tx1 = rx1 end
	if (ty1 > ry1) then ty1 = ry1 end
	if (tx2 < rx2) then tx2 = rx2 end
	if (ty2 < ry2) then ty2 = ry2 end
	tx2 = tx2 - tx1
	ty2 = ty2 - ty1
	-- tx2,ty2 will never underflow since both original rectangles
	-- were already proven to be non-empty
	-- they might overflow, though...
	if (tx2 > Integer.MAX_VALUE) then tx2 = Integer.MAX_VALUE end
	if (ty2 > Integer.MAX_VALUE) then ty2 = Integer.MAX_VALUE end
	return Rectangle(tx1, ty1, tx2, ty2)
end
	
function Rectangle:add(...)
	if(instanceOf(arg[1],Rectangle)) then
		local tx2 = self.width
		local ty2 = self.height
		if (tx2 < 0 or ty2 < 0) then
			self:reshape(r.x, r.y, r.width, r.height)
		end
		local rx2 = r.width
		local ry2 = r.height
		if (rx2 < 0 or ry2 < 0) then
			return
		end
		local tx1 = self.x
		local ty1 = self.y
		tx2 = tx2 + tx1
		ty2 = ty2 + ty1
		local rx1 = r.x
		local ry1 = r.y
		rx2 = rx2 + rx1
		ry2 = ry2 + ry1
		if (tx1 > rx1) then tx1 = rx1 end
		if (ty1 > ry1) then ty1 = ry1 end
		if (tx2 < rx2) then tx2 = rx2 end
		if (ty2 < ry2) then ty2 = ry2 end
		tx2 = tx2 - tx1
		ty2 = ty2 - ty1
		-- tx2,ty2 will never underflow since both original
		-- rectangles were non-empty
		-- they might overflow, though...
		if (tx2 > Integer.MAX_VALUE) then tx2 = Integer.MAX_VALUE end
		if (ty2 > Integer.MAX_VALUE) then ty2 = Integer.MAX_VALUE end
		self:reshape(tx1, ty1, tx2, ty2)
	else
		local newx
		local newy
		if(type(arg[1]) == "number") then
			newx = arg[1] or 0
			newy = arg[2] or 0
		elseif(type(arg[1]) == "table") then
			newx = arg[1].x or 0
			newy = arg[1].y or 0
		end
        if (self.width < 0 or self.height < 0) then
            self.x = newx
            self.y = newy
            self.width = 0
			self.height = 0
            return
        end
        local x1 = self.x
        local y1 = self.y
        local x2 = self.width
        local y2 = self.height
        x2 = x2 + x1
        y2 = y2 + y1
        if (x1 > newx) then x1 = newx end
        if (y1 > newy) then y1 = newy end
        if (x2 < newx) then x2 = newx end
        if (y2 < newy) then y2 = newy end
        x2 = x2 - x1
        y2 = y2 - y1
        if (x2 > Integer.MAX_VALUE) then x2 = Integer.MAX_VALUE end
        if (y2 > Integer.MAX_VALUE) then y2 = Integer.MAX_VALUE end
        self:reshape(x1, y1, x2, y2)	
	end
end

function Rectangle:grow(h, v)
	local x0 = self.x
	local y0 = self.y
	local x1 = self.width
	local y1 = self.height
	
	x1 = x1 + x0
	y1 = y1 + y0

	x0 = x0 - h
	y0 = y0 - v
	x1 = x1 + h
	y1 = y1 + v

	if (x1 < x0) then
		-- Non-existant in X direction
		-- Final width must remain negative so subtract x0 before
		-- it is clipped so that we avoid the risk that the clipping
		-- of x0 will reverse the ordering of x0 and x1.
		x1 = x1 - x0;
		if (x1 < Integer.MIN_VALUE) then x1 = Integer.MIN_VALUE end 
		if (x0 < Integer.MIN_VALUE) then x0 = Integer.MIN_VALUE 
		elseif (x0 > Integer.MAX_VALUE) then x0 = Integer.MAX_VALUE end
	else -- (x1 >= x0)
		-- Clip x0 before we subtract it from x1 in case the clipping
		-- affects the representable area of the rectangle.
		if (x0 < Integer.MIN_VALUE) then x0 = Integer.MIN_VALUE
		elseif (x0 > Integer.MAX_VALUE) then x0 = Integer.MAX_VALUE end 
		x1 = x1 - x0
		-- The only way x1 can be negative now is if we clipped
		-- x0 against MIN and x1 is less than MIN - in which case
		-- we want to leave the width negative since the result
		-- did not intersect the representable area.
		if (x1 < Integer.MIN_VALUE) then x1 = Integer.MIN_VALUE
		elseif (x1 > Integer.MAX_VALUE) then x1 = Integer.MAX_VALUE end
	end

	if (y1 < y0) then
		-- Non-existant in Y direction
		y1 = y1 - y0;
		if (y1 < Integer.MIN_VALUE) then y1 = Integer.MIN_VALUE end
		if (y0 < Integer.MIN_VALUE) then y0 = Integer.MIN_VALUE
		elseif (y0 > Integer.MAX_VALUE) then y0 = Integer.MAX_VALUE end
	else -- (y1 >= y0)
		if (y0 < Integer.MIN_VALUE) then y0 = Integer.MIN_VALUE
		elseif (y0 > Integer.MAX_VALUE) then y0 = Integer.MAX_VALUE end
		y1 = y1 - y0
		if (y1 < Integer.MIN_VALUE) then y1 = Integer.MIN_VALUE
		elseif (y1 > Integer.MAX_VALUE) then y1 = Integer.MAX_VALUE end
	end

	self:reshape(x0, y0, x1, y1)
end

function Rectangle:isEmpty()
    return self.width <= 0 or self.height <= 0
end

function Rectangle:outcode(x, y)
	local out = 0
	if (self.width <= 0) then
		out = bitOr(out, Rectangle.OUT_LEFT, Rectangle.OUT_RIGHT)
	elseif (x < self.x) then
		out = bitOr(out, Rectangle.OUT_LEFT)
	elseif (x > self.x + self.width) then
		out = bitOr(out, Rectangle.OUT_RIGHT)
	end
	
	if (self.height <= 0) then
		out = bitOr(out, Rectangle.OUT_TOP, Rectangle.OUT_BOTTOM)
	elseif(y < self.y) then
		out = bitOr(out, Rectangle.OUT_TOP)
	elseif(y > self.y + self.height) then
		out = bitOr(out, Rectangle.OUT_BOTTOM)
	end
	return out
end

function Rectangle:equals(obj)
	if (instanceOf(obj,Rectangle) ) then
		local pt = obj
		return (self.x == pt.x) and (self.y == pt.y)
	end
	return super.equals(self, obj)
end
