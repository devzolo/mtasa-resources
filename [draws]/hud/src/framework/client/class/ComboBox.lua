local super = Class("ComboBox", Container, function()
	static.DEFAULT_STYLE_CLASS = "combo-box"
	static.Value = Class("ComboBox.Value", LuaObject)
end).getSuperclass()

function ComboBox:init(v)
	super.init(self)
	self.values = {}

	self.currentComboBoxValue = nil
	self.currentValue = Label()
	self.currentValue:setText("")
	self.currentValue:setScale(Graphics.relativeH(1))
	self.currentValue:setForeground(tocolor(230,230,230, 255))
	self.currentValue:setAlignment(Label.CENTER)
	self.currentValue:setBounds(0,0,0,0)
	self.currentValue:addMouseListener(self)
	self:add(self.currentValue)

	self.list = Table()
	self.list:setBounds(0,0,0,0)
	self.list:setForeground(tocolor(255,255,255))
	self.list:setBackground(tocolor(20,20,20))		
	self.list:addMouseListener(self)
	self.list:addMouseWheelListener(self)
	self.list:setZOrder(66)
	self.list:setColumns({
		{name='Select',w=(self.list:getWidth()), align="left"},
	})
	self.list:setVisible(false)
	self:add(self.list)

	self.selectValue = function (value)
		self.currentComboBoxValue = value
		self.currentValue:setText(value:getName())
		value:setSelected(true)
		self:processSelector()
	end

	self:addMouseListener(self)

	if (type(v) == "table") then
		for i, valueName in ipairs (v) do
			self:addValue(valueName)
		end
	end

	return self
end

function ComboBox:setBounds(x,y,w,h, list)
	if not (list) then
		self.currentValue:setBounds(0,0,w,h)
		self.list:setBounds(0, h, w, Graphics.relativeH(100))
		self.defaultH = h
		self.list:setColumns({
			{name='ComboBox',w=(self.list:getWidth()), align="left"},
		})
	end
	super.setBounds(self, x,y,w,h)
end

function ComboBox:paint(g)
	local x, y = self:getLocationOnScreen()
	local w = self:getWidth()
	local h = self.defaultH

	g:drawSetColor( self:getForeground() )
	g:drawFilledRect(x,   y,   w, 1)
	g:drawFilledRect(x+w, y,   1, h)
	g:drawFilledRect(x,   y,   1, h)
	g:drawFilledRect(x,   y+h, w, 1)

	g:drawSetColor( self:getBackground() )
	g:drawFilledRect(x + 1, y + 1, w - 1, h - 1)

	g:drawSetColor( tocolor(100,100,100,255) )
	local width = Graphics.relativeW(20)
	g:drawFilledRect(x+(w-width), y+1, width, h-1)

	local b = 6
	g:drawSetColor( tocolor(200,200,200,255) )
	g:drawLine( x + (w-width) + b, y+b,  x+(w-width) + (width-b), y+b)
	g:drawLine( x + (w-width) + b, y+b,  x+(w-width/2), y+(width/2)+b)
	g:drawLine( x+(w-width) + (width-b), y+b,  x+(w-width/2), y+(width/2)+b)

	super.paint(self, g)
end

function ComboBox:addValue(valueName, selected)
	local id = #self.values+1
	local value = ComboBox.Value(id, valueName)
	table.insertUnique(self.values, value)
	self.list:addRow(id, {valueName}, value, self.selectValue)
	if (selected) then
		value:setSelected(true)
		self.currentValue:setText(valueName)
		self.list:resetSelectedRow()
		self.list:setRowSelected(id)
	end
end

function ComboBox:removeValue(valueName)
	for i, v in ipairs (self.values) do
		if (v:getName() == valueName) then
			table.remove(self.values, i)
			self.list:removeRow(id)
		end
	end
end

function ComboBox:getSelectedValue()
	for i, v in ipairs (self.values) do
		if (v:isSelected()) then
			return v
		end
	end
	return false
end

function ComboBox:mouseReleased(e)
	outputDebugString("ComboBox: mouseReleased")
	self:processSelector()
end

function ComboBox:processSelector()
	local visible = not self.list:isVisible()
	self.list:setVisible(visible)

	local x,y,w,h = self.list:getBounds()
	x, y = self:getX(), self:getY()
	if (visible) then
		self:setBounds(x,y, w, self:getHeight() + h, true)
	else
		self:setBounds(x,y, w, self.defaultH, true)
	end
end

-------------------------------------------------

local super = ComboBox.Value.getSuperclass()

function ComboBox.Value:init(id, name)
	super.init(self)
	self.id = id
	self.name = name
	self.selected = false
	return self
end

function ComboBox.Value:getID()
	return self.id
end

function ComboBox.Value:getName()
	return self.name
end

function ComboBox.Value:setSelected(bool)
	self.selected = bool
end

function ComboBox.Value:isSelected()
	return self.selected
end