local super = Class("Frame", Window).getSuperclass()

Frame.DO_NOTHING_ON_CLOSE = 0
Frame.HIDE_ON_CLOSE = 1
Frame.DISPOSE_ON_CLOSE = 2
Frame.EXIT_ON_CLOSE = 3
	
function Frame:init(title)
	super.init(self)
	self.title = title or "Untitled"
	self:frameInit()
	
	return self
end

function Frame:frameInit()
	--self:enableEvents(Event.KEY_EVENT_MASK, Event.WINDOW_EVENT_MASK)
	self:setRootPane(self:createRootPane())
	--self:setBackground(UIManager.getColor("control"))
	self:getRootPane():setBackground(UIManager.getColor("control"))
	self:setRootPaneCheckingEnabled(true)	
	self.labelTitle = Label(self.title)
	self.labelTitle:setBounds(0,0, 100, 20)
	self.labelTitle:setBackground(UIManager.getColor("controlText"))
	self.border = BorderFactory.createLineBorder(UIManager.getColor("windowBorder"):getRGB(), 3)
	self.labelTitle.decorator = true
	local checkingEnabled = self:isRootPaneCheckingEnabled()
	self:setRootPaneCheckingEnabled(false)
	self:add(self.labelTitle)
	self:setRootPaneCheckingEnabled(checkingEnabled)
	self:addMouseListener(self)
end

function Frame:createRootPane()
	local rp = RootPane()
	rp:setOpaque(true)
	return rp
end

function Frame:getRootPane()
	return self.rootPane
end

function Frame:getLayeredPane()
	return self:getRootPane():getLayeredPane()
end

function Frame:getContentPane()
	return self:getRootPane():getContentPane()
end
	
function Frame:setRootPane(rootPane) 
	if(self.rootPane ~= nil) then
		self:remove(self.rootPane)
	end
	self.rootPane = rootPane
	if(self.rootPane ~= nil) then
		local checkingEnabled = self:isRootPaneCheckingEnabled()
		self:setRootPaneCheckingEnabled(false)
		self:add(self.rootPane, BorderLayout.CENTER)
		self:setRootPaneCheckingEnabled(checkingEnabled)
	end
end	
	
function Frame:isRootPaneCheckingEnabled()
	return self.rootPaneCheckingEnabled
end

function Frame:setRootPaneCheckingEnabled(enabled)
	self.rootPaneCheckingEnabled = enabled
end	
	

	
function Frame:getTitle()
	return self.title
end

function Frame:setTitle(title)
	local oldTitle = self.title;
	if (title == nil) then
		title = ""
	end
	self.title = title
	self:firePropertyChange("title", oldTitle, title)
end

function Frame:addNotify()
	local menuBar = self.menuBar
	if (menuBar ~= nil) then
		menuBar:addNotify()
	end
	super.addNotify(self)
end

function Frame:getMenuBar()
	return self.menuBar
end

function Frame:setBounds(x,y,w,h)
	super.setBounds(self, x, y, w, h)
	self.labelTitle:setBounds(0,0, w, 20)
	self:getRootPane():setBounds(0, 20, w, h-20)
	local rect = Utilities.getLocalBounds(self:getRootPane())
	self:getLayeredPane():setBounds(0, 0, rect:getWidth(), rect:getHeight())
	self:getContentPane():setBounds(0, 0, rect:getWidth(), rect:getHeight())
end

function Frame:add(comp, index, constraints)
	if(self:isRootPaneCheckingEnabled()) then
		self:getContentPane():add(comp, constraints, index)
	else
		super.add(self, comp, index, constraints);
	end
end

function Frame:remove(component)
	if(self:isRootPaneCheckingEnabled()) then
		self:getContentPane():remove(comp)
	else
		super.remove(self, comp)
	end
end

function Frame:paintComponent(g)
	self:processDrag()
	
	local x, y = self:getLocationOnScreen()
	local w = self.width
	local h = self.height
	
	g:drawSetColor(self:getBackground())
	g:drawFilledRect(x, y, w, h)
	
	super.paintComponent(self,g)
end

function Frame:processDrag()
	if(self.isDragging) then
		if(Utilities.isLeftMouseButton()) then
			local cx,cy = MouseInfo.getPoint()
			self:setLocation(cx - self.dragX, cy - self.dragY)
		else
			self.isDragging = false
		end
	end
end

function Frame:mousePressed(e)
	outputDebugString("Frame:mousePressed")
	if(e:getButton() == MouseEvent.BUTTON1) then
		self.isDragging = true
		self.dragX, self.dragY = e:getLocation()
	end
end
