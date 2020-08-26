local super = Class("ColorChooser", Panel, function()
end).getSuperclass()

function ColorChooser:init()
	super.init(self)
	
	--self.width = 350
	--self.height = 430
	self.paletteX = 0
	self.paletteY = 0
	self.luminanceOffset = 10
	self.luminanceWidth = 15
	self.alphaOffset = 25 + 17
	self.alphaWidth = 15
	self.rgbX = 265
	self.rgbY = 300
	self.rgbWidth = 50
	self.rgbHeight = 21
	self.hslX = 190
	self.hslY = 300
	self.hslWidth = 50
	self.hslHeight = 21
	self.historyX = 18
	self.historyY = 300
	self.historyWidth = 140
	self.historyHeight = 80
	self.noteX = 18
	self.noteY = 378
	self.ra1X = 18
	self.ra1Y = 398
	self.ra2X = 88
	self.ra2Y = 398
	self.ra3X = 168
	self.ra3Y = 398
	self.l = 0.5
	self.a = 127
	
	self.palette = Image()
	self.palette:setSource("gfx/components/colorpicker/palette.png")
	self.palette:setBounds(0, 0, self:getWidth(), self:getHeight())	
	self.palette:setColor(tocolor(255, 255, 255))
	self.palette:addMouseListener(self)
	self.palette:addMouseMotionListener(self)
	self:add(self.palette)
	
	self.luminanceBar = Component()
	self.luminanceBar:setBounds(0, 0, self:getWidth(), self:getHeight())
	self.luminanceBar:addMouseListener(self)
	self.luminanceBar:addMouseMotionListener(self)
	self:add(self.luminanceBar)		
	
	self.alphaBar = Image()
	self.alphaBar:setSource("gfx/components/colorpicker/alpha.png")
	self.alphaBar:setBounds(0, 0, self:getWidth(), self:getHeight())	
	self.alphaBar:setColor(tocolor(255, 255, 255))
	self.alphaBar:addMouseListener(self)
	self.alphaBar:addMouseMotionListener(self)	
	self:add(self.alphaBar)
	

	self:addMouseListener(self)

	return self
end

function ColorChooser:processDrag()
	if(self.isDragging) then
		if(Utilities.isLeftMouseButton()) then
			local cx,cy = MouseInfo.getPoint()
			self:setLocation(cx - self.dragX, cy - self.dragY)
		else
			self.isDragging = false
		end
	end
end

function ColorChooser:fireStateChanged()
	if(self.changeEvent == nil) then
		self.changeEvent = ChangeEvent(self)
	end
    if (self.changeListener ~= nil) then
		Component.executeListener(self.changeListener, "stateChanged", self.changeEvent)
    end	
end


function ColorChooser:pick(e)
	--if(self.isDragging) then 
	--	return 
	--end
	
	if(e.source == self.palette) then
		local x, y = e:getLocation()
		self.h = x / self.palette:getWidth()
		self.s = (self.palette:getHeight() - y) / self.palette:getHeight()
	elseif(e.source == self.luminanceBar) then
		local x, y = e:getLocation()
		self.l = (self.luminanceBar:getHeight() - y) / self.luminanceBar:getHeight()
	elseif(e.source == self.alphaBar) then
		local x, y = e:getLocation()
		self.a = 255 * y / self.alphaBar:getHeight()
	end
	local _r, _g, _b = self:hsl2rgb(self.h or 0, self.s or 0, self.l or 0)
	local a = self.a or 255
	self.color = tocolor(_r * 255, _g * 255, _b * 255, a)
	self:fireStateChanged()
end

function ColorChooser:getColor()
	return self.color
end


function ColorChooser:setColorRGBA(r, g, b, a)
	self.h, self.s, self.l = self:rgb2hsl(r/255, g/255, b/255)
	self.a = a
end

function ColorChooser:getColorRGBA()
	local _r, _g, _b = self:hsl2rgb(self.h or 0, self.s or 0, self.l or 0)
	local r, g, b, a = _r * 255, _g * 255, _b * 255, (self.a or 255)
	return r, g, b, a
end

function ColorChooser:mouseEntered(e)
end

function ColorChooser:mouseExited(e)
end

function ColorChooser:mouseMoved(e) 
end

function ColorChooser:mouseDragged(e)
	if(Utilities.isLeftMouseButton(e)) then
		self:pick(e)
	end
end

function ColorChooser:mousePressed(e)
	if(e:getButton() == MouseEvent.BUTTON1) then
		if(e.source == self) then
			--self.isDragging = true
			--self.dragX, self.dragY = e:getLocation()
		else
			self:pick(e)
		end
	end
end

function ColorChooser:mouseReleased(e)
end

function ColorChooser:paint(g)
	--self:processDrag()
	
	local x, y = self:getLocationOnScreen()
	local w = self:getWidth()
	local h = self:getHeight()
	super.paint(self, g)
	
	-- Draw the lines pointing to the current selected color
	local cx = x + self.paletteX + ((self.h or 0) * self.palette:getWidth())
	local cy = y + self.paletteY + ((1 - (self.s or 0)) * self.palette:getHeight())
	
	g:drawSetColor(tocolor(0, 0, 0, 255))
	g:drawSetLineWidth(3)
	g:drawLine(cx - 12, cy, cx - 2, cy)
	g:drawLine(cx + 2, cy, cx + 12, cy)
	g:drawLine(cx, cy - 12, cx, cy - 2)
	g:drawLine(cx, cy + 2, cx, cy + 12)	
	
	-- Draw the luminance for this color
	local i
	for i=0, self.luminanceBar:getHeight() do
		local _r, _g, _b = self:hsl2rgb(self.h or 0, self.s or 0, (256 - (i*(256/self.alphaBar:getHeight())) ) / 256)
		--local _r, _g, _b = self:hsl2rgb(self.h or 0, self.s or 0, (256 - i) / 256)
		g:drawSetColor(tocolor(_r * 255, _g * 255, _b * 255, 255))
		g:drawFilledRect(x + self.luminanceBar:getX(), y + self.luminanceBar:getY() + i, self.luminanceBar:getWidth(), 1)
	end	
	
	-- Draw the luminance position marker
	local arrowX = x + self.luminanceBar:getX() + self.luminanceBar:getWidth() + 4
	local arrowY = y + self.luminanceBar:getY() + ((1 - (self.luminanceBar:getHeight() * (self.l or 0)/self.luminanceBar:getHeight())) * self.luminanceBar:getHeight())
	g:drawSetColor(tocolor(255, 255, 255, 255))
	g:drawSetLineWidth(2)	
	g:drawLine(arrowX, arrowY, arrowX + 8, arrowY)	
	
	if(self.alphaBar:isVisible()) then
		-- Draw the alpha for this color
		local _r, _g, _b = self:hsl2rgb(self.h or 0, self.s or 0, self.l or 0)
		for i=0, self.alphaBar:getHeight() do
			g:drawSetColor(tocolor(_r * 255, _g * 255, _b * 255, i*(255/self.alphaBar:getHeight())))
			g:drawFilledRect(x + self.alphaBar:getX(), y + self.alphaBar:getY() + i, self.alphaBar:getWidth(), 1)
		end	
		
		-- Draw the alpha position marker
		arrowX = x + self.alphaBar:getX() + self.alphaBar:getWidth() + 4
		arrowY = y + self.alphaBar:getY() + ((self.alphaBar:getHeight() * (self.a or 255)/255))
		g:drawSetColor(tocolor(255, 255, 255, 255))
		g:drawSetLineWidth(2)	
		g:drawLine(arrowX, arrowY, arrowX + 8, arrowY)		
	end
end

function ColorChooser:setBounds(x,y,w,h)
	super.setBounds(self, x,y,w,h)
	
	local paletteSize = h - self.paletteY * 2
 
	self.palette:setBounds(self.paletteX, self.paletteY, paletteSize, paletteSize)	
	self.luminanceBar:setBounds(self.paletteX + self.palette:getWidth() + self.luminanceOffset, self.paletteY, self.luminanceWidth, self.palette:getWidth())
	self.alphaBar:setBounds(self.paletteX + self.palette:getWidth() + self.alphaOffset, self.paletteY, self.alphaWidth, self.palette:getWidth())
end

function ColorChooser:hue2rgb(m1, m2, h)
	if h < 0 then h = h + 1
	elseif h > 1 then h = h - 1 end

	if h*6 < 1 then
		return m1 + (m2 - m1) * h * 6
	elseif h*2 < 1 then
		return m2
	elseif h*3 < 2 then
		return m1 + (m2 - m1) * (2/3 - h) * 6
	else
		return m1
	end
end

function ColorChooser:hsl2rgb(h, s, l)
	local m2
	if l < 0.5 then
		m2 = l * (s + 1)
	else
		m2 = (l + s) - (l * s)
	end
	local m1 = l * 2 - m2

	local r = self:hue2rgb(m1, m2, h + 1/3)
	local g = self:hue2rgb(m1, m2, h)
	local b = self:hue2rgb(m1, m2, h - 1/3)
	return r, g, b
end

function ColorChooser:rgb2hsl(r, g, b)
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local l = (min + max) / 2
	local h
	local s

	if max == min then
		h = 0
		s = 0
	else
		local d = max - min

		if l < 0.5 then
			s = d / (max + min)
		else
			s = d / (2 - max - min)
		end

		if max == r then
			h = (g - b) / d
			if g < b then h = h + 6 end
		elseif max == g then
			h = (b - r) / d + 2
		else
			h = (r - g) / d + 4
		end

		h = h / 6
	end
	return h, s, l
end
