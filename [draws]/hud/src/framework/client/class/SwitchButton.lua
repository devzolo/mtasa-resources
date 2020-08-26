local super = Class("SwitchButton", Button).getSuperclass()

function SwitchButton.static()
	SwitchButton.WHITE = tocolor(255,255,255,255)
	SwitchButton.GREEN = tocolor(76, 215, 100,255)
	SwitchButton.GRAY = tocolor(200,200,200,255)
end


function SwitchButton:init(...)
	super.init(self, ...)
	self.border = nil
	self.selected = false
	return self
end

function SwitchButton:paintComponent(g)
	local x, y = self:getLocationOnScreen()
	local w = self:getWidth()
	local h = self:getHeight()
	
	g:drawSetColor(self.selected and SwitchButton.GREEN or SwitchButton.GRAY)
	g:drawImage(x, y, w, h, "gfx/control/toggle/background.png", 0, 0, 0)
	
	g:drawSetColor(SwitchButton.WHITE)
	if(self.selected) then
		g:drawImage(x + w - h, y, h, h, "gfx/control/toggle/pin.png", 0, 0, 0)	
	else
		g:drawImage(x, y, h, h, "gfx/control/toggle/pin.png", 0, 0, 0)	
	end
end

function SwitchButton:setSelected(selected)
	self.selected = selected
end

function SwitchButton:isSelected()
	return self.selected 
end

function SwitchButton:actionPerformed(e)
	self:setSelected(not self:isSelected())
end