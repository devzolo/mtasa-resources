local super = Class("Window", Container).getSuperclass()

Window.OPENED = 0x01
Window.base = "win"
Window.nameCounter = 0

function Window:init()
	super.init(self)
	self.warningString = ""
	self.icons = nil
	self.temporaryLostComponent = nil
	self.beforeFirstShow = false
	self.state = 0
	self.alwaysOnTop = false
	self.showWithParent = false
	self.modalBlocker = nil
	self.modalExclusionType = nil

    self.windowListener = nil
    self.windowStateListener = nil
    self.windowFocusListener = nil


    self.inputContext = nil
    self.focusableWindowState = nil
    self.isInShow = false

	return self
end


function Window:paint(g)
	if (not self:isOpaque()) then
		local x, y = self:getLocationOnScreen()
		g:drawSetColor(self:getBackground())
		g:drawFilledRect(x, y, self:getWidth(), self:getHeight())
	end
	super.paint(self, g)
end