local super = Class("RootPane", Panel).getSuperclass()

RootPane.NONE = 0
RootPane.FRAME = 1
RootPane.PLAIN_DIALOG = 2
RootPane.INFORMATION_DIALOG = 3
RootPane.ERROR_DIALOG = 4
RootPane.COLOR_CHOOSER_DIALOG = 5
RootPane.FILE_CHOOSER_DIALOG = 6
RootPane.QUESTION_DIALOG = 7
RootPane.WARNING_DIALOG = 8

function RootPane:init()
	super.init(self)
	self:setGlassPane(self:createGlassPane());
	self:setLayeredPane(self:createLayeredPane())
	self:setContentPane(self:createContentPane())
	return self
end

function RootPane:setGlassPane(glass)
	if (glass == nil) then
		outputDebugString("glassPane cannot be set to null.");
	end

	--Accessor.getComponentAccessor():setMixingCutoutShape(glass, Rectangle());

	local visible = false
	if (self.glassPane ~= nil and self.glassPane:getParent() == self) then
		self:remove(self.glassPane)
		visible = self.glassPane:isVisible()
	end

	glass:setVisible(visible);
	self.glassPane = glass
	self:add(self.glassPane, 0)
	if (visible) then
		self:repaint()
	end
end

function RootPane:setLayeredPane(layered)
	if(layered == nil) then
		outputDebugString("layeredPane cannot be set to null.")
	end
	if(self.layeredPane ~= nil and self.layeredPane:getParent() == self) then
		self:remove(self.layeredPane)
	end
	self.layeredPane = layered

	self:add(self.layeredPane, -1);
end

function RootPane:setContentPane(content)
	if(content == nil) then
		outputDebugString("contentPane cannot be set to null.")
	end
	if(self.contentPane ~= nil and self.contentPane:getParent() == self.layeredPane) then
		self.layeredPane:remove(self.contentPane)
	end
	
	self.contentPane = content
	self.layeredPane:add(self.contentPane, LayeredPane.FRAME_CONTENT_LAYER)
end

function RootPane:getLayeredPane()
	return self.layeredPane
end

function RootPane:getContentPane()
	return self.contentPane
end

function RootPane:createGlassPane()
	local c = Panel()
	c:setName(self:getName() .. ".glassPane")
	c:setVisible(true)
	c:setBackground(UIManager.getColor("red"))
	c:setOpaque(false)
	return c
end

function RootPane:createLayeredPane()
	local p = LayeredPane()
	p:setName(self:getName() .. ".layeredPane");
	return p
end

function RootPane:createContentPane()
	local c = Panel()
	c:setName(self:getName() .. ".contentPane")
	return c
end

