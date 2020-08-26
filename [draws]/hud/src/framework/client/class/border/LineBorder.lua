local super = Class("LineBorder", AbstractBorder).getSuperclass()

function LineBorder:init(color, thickness)
	super.init(self)
	self.color = color or tocolor(0,0,0)
	self.thickness = thickness or 1
	return self
end

function LineBorder:paintBorder(c, g, x, y, width, height) 
	local offs = self.thickness
    local size = offs + offs
	g:drawSetColor(self.color)
	g:drawFilledRect(x, y, offs, height) -- Left
	g:drawFilledRect(x + width - offs, y, offs, height) -- Right
	g:drawFilledRect(x + offs, y, width - size, offs) -- Top
	g:drawFilledRect(x + offs, y + height - offs, width - size, offs) -- Botton
end

