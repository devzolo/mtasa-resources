local super = Class("Dialog", Window, function()
	
	static.ModalityType = {
		MODELESS = 1,
		DOCUMENT_MODAL = 2,
		APPLICATION_MODAL = 3,
		TOOLKIT_MODAL = 4,
	}
	
	static.DEFAULT_MODALITY_TYPE = static.ModalityType.APPLICATION_MODAL
	
    static.ModalExclusionType = {
        NO_EXCLUDE = 1,
        APPLICATION_EXCLUDE = 2,
        TOOLKIT_EXCLUDE = 3,
    }
	
	static.modalDialogs = ArrayList()
	
    static.base = "dialog"
    static.nameCounter = 0;
end).getSuperclass()

function Dialog:init(owner, title, modal)
	super.init(self)
	self.resizable = true
	self.undecorated = false
	self.initialized = false
	self.modal = false
	self.modalityType = Dialog.DEFAULT_MODALITY_TYPE
	self.blockedWindows = ArrayList()
	self.title = ""
    self.modalFilter = nil
    self.secondaryLoop = nil
	self.isInHide = false
	self.isInDispose = false
	
	self.defaultCloseOperation = HIDE_ON_CLOSE
	self:dialogInit()
	return self
end

function Dialog:dialogInit()
	self:setRootPane(self:createRootPane())
end

function Dialog:getRootPane()
	return self.rootPane
end

function Dialog:getContentPane()
	return self:getRootPane():getContentPane()
end

function Dialog:setRootPane(rootPane)
	if(self.rootPane ~= nil) then
		self:remove(self.rootPane)
	end
	self.rootPane = rootPane
	if(self.rootPane ~= nil) then
		local checkingEnabled = self:isRootPaneCheckingEnabled();
		try(function()
			self:setRootPaneCheckingEnabled(false);
			self:add(self.rootPane, BorderLayout.CENTER)
		end,
		nil,
		function()
			self:setRootPaneCheckingEnabled(checkingEnabled)
		end)
	end
end

function Dialog:createRootPane()
	local rp = RootPane()
	--rp:setOpaque(true)
	return rp
end

function Dialog:processWindowEvent(e)
	super.processWindowEvent(self, e)
	if (e:getID() == WindowEvent.WINDOW_CLOSING) then
		if(self.defaultCloseOperation == HIDE_ON_CLOSE) then
			self:setVisible(false)
		elseif(self.defaultCloseOperation == DISPOSE_ON_CLOSE) then
			self:dispose()
		elseif(self.defaultCloseOperation == DO_NOTHING_ON_CLOSE) then
			--nop
		end
	end
end


function Dialog:setDefaultCloseOperation(operation)
	if (operation ~= DO_NOTHING_ON_CLOSE and
		operation ~= HIDE_ON_CLOSE and
		operation ~= DISPOSE_ON_CLOSE) then
		throw("IllegalArgumentException: defaultCloseOperation must be one of: DO_NOTHING_ON_CLOSE, HIDE_ON_CLOSE, or DISPOSE_ON_CLOSE")
	end

	local oldValue = self.defaultCloseOperation
	self.defaultCloseOperation = operation;
	self:firePropertyChange("defaultCloseOperation", oldValue, operation)
end

function Dialog:getDefaultCloseOperation()
    return self.defaultCloseOperation
end

function Dialog:isRootPaneCheckingEnabled()
	return self.rootPaneCheckingEnabled
end

function Dialog:setRootPaneCheckingEnabled(enabled)
	self.rootPaneCheckingEnabled = enabled
end

function Dialog:addImpl(comp, constraints, index)
	if(self:isRootPaneCheckingEnabled()) then
		self:getContentPane():add(comp, constraints, index)
	else
		super.addImpl(self, comp, constraints, index);
	end
end

function Dialog:remove(comp)
	if (comp == self.rootPane) then
		super.remove(self, comp);
	else
		self:getContentPane():remove(comp)
	end
end

function Dialog:setLayout(manager)
	if(self:isRootPaneCheckingEnabled()) then
		self:getContentPane():setLayout(manager)
	else
		super.setLayout(self, manager)
	end
end
	
function Dialog:getRootPane()
	return self.rootPane
end

function Dialog:setRootPane(root)
	if(self.rootPane ~= nil) then
		self:remove(rootPane)
	end
	self.rootPane = root;
	if(self.rootPane ~= nil) then
		local checkingEnabled = self:isRootPaneCheckingEnabled()
		try(function()
			self:setRootPaneCheckingEnabled(false)
			self:add(self.rootPane, BorderLayout.CENTER)
		end,
		nil,
		function()
			setRootPaneCheckingEnabled(checkingEnabled)
		end)
	end
end

function Dialog:getContentPane()
	return self:getRootPane():getContentPane()
end

function Dialog:setContentPane(contentPane)
	self:getRootPane():setContentPane(contentPane)
end


function Dialog:getLayeredPane()
	return self:getRootPane():getLayeredPane()
end

function Dialog:setLayeredPane(layeredPane)
	self:getRootPane():setLayeredPane(layeredPane);
end

function Dialog:getGlassPane()
	return self:getRootPane():getGlassPane()
end

function Dialog:setGlassPane(glassPane)
	self:getRootPane():setGlassPane(glassPane)
end

function Dialog:getGraphics()
	Component.getGraphicsInvoked(self)
	return super.getGraphics(self)
end
	
function Dialog:repaint(time, x, y, width, height)
	if (RepaintManager.HANDLE_TOP_LEVEL_PAINT) then
		RepaintManager.currentManager(self):addDirtyRegion(self, x, y, width, height);
	else
		super.repaint(self, time, x, y, width, height);
	end
end	