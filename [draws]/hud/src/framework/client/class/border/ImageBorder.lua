local super = Class("ImageBorder", AbstractBorder).getSuperclass()

function ImageBorder:init(image, fillCenter,
	topSlice, rightSlice, bottomSlice, leftSlice,
    repeatX, repeatY, 
	proportionalSlice, proportionalWidth,
    topWidth, rightWidth, bottomWidth, leftWidth,
    offsets)
	
	super.init(self)
	self.color = color or tocolor(0,0,0)
	self.thickness = thickness or 1
	
	
	
    --super(topWidth, rightWidth, bottomWidth, leftWidth, proportionalWidth, offsets);
	self.image = image
	self.fillCenter = fillCenter
	self.topSlice = topSlice
	self.rightSlice = rightSlice
	self.bottomSlice = bottomSlice
	self.leftSlice = leftSlice
	self.repeatX = repeatX
	self.repeatY = repeatY
	self.proportionalSlice = proportionalSlice;
	
	return self
end

function ImageBorder:paintBorder(c, g, x, y, width, height) 
	local offs = self.thickness
    local size = offs + offs
	g:drawSetColor(self.color)
	g:drawFilledRect(x, y, offs, height) -- Left
	g:drawFilledRect(x + width - offs, y, offs, height) -- Right
	g:drawFilledRect(x + offs, y, width - size, offs) -- Top
	g:drawFilledRect(x + offs, y + height - offs, width - size, offs) -- Botton
end

