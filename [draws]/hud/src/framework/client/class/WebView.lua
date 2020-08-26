local super = Class("WebView", Container).getSuperclass()
   
function WebView:init(width, height, startPage, transparent, mobile)
	super.init(self)
	
	self:addMouseListener(self)
	self:addMouseMotionListener(self)	
	self:addMouseWheelListener(self)
	
	self.blocal = true
	self.currentURL = startPage
	self.transparent = transparent or false
	self.mobile = mobile or false
	self.paused = false
	self.autorender = true
	self.volume = 1
	
	
	self.posX = 0
	self.posY = 0
	
	self.width = width
	self.height = height

	self.post = false
	self.speedScroll = 50
	self:setBounds(0, 0, width, height)
	
	
	-- listener
	self.createListener = false
	self.readyListener = false
	self.whitelistChangeListener = false

	-- input
	self.mouseEnabled = true
	self.scrollEnabled = true
	self.clickEnabled = true

	self.currentFuncID = 0
	self.funcsID = {}

	-- add event
	self.tempCreate = function ()
		self:onBrowserCreated()
	end

	self.documentReady = function (url)
		if (self.readyListener) then
			self.readyListener:onDocumentReady(url)
		end
	end

	self.onClientBrowserWhitelistChangeHandler = function (...)
		if (self.whitelistChangeListener and self.whitelistChangeListener.onWhitelistChange) then
			self.whitelistChangeListener:onWhitelistChange({source = self, whitelist = {...}})
		end
	end	

	
	if (startPage) then
		if (self:checkIfIsLocal(startPage)) then
			self.blocal = true
		end

		self.browser = createBrowser(width, height, self:isLocal(), self:isTransparent())
		if(self.mobile) then
			self.browser:setProperty("mobile", "1")
		end
		addEventHandler("onClientBrowserCreated", self:getBrowser(), self.tempCreate)
		addEventHandler("onClientBrowserDocumentReady", self:getBrowser(), self.documentReady)
		addEventHandler("onClientBrowserWhitelistChange", root, self.onClientBrowserWhitelistChangeHandler)
	end
	--[[
	-- input inject
	self.mouseMove = function (relX, relY, x, y)
		if not (isElement(self:getBrowser())) then
			return
		end

		self:onBrowserMouseMove(x,y)
	end
	addEventHandler("onClientCursorMove", root, self.mouseMove)

	self.mouseWheel = function (button)
		if not (isElement(self:getBrowser())) then
			return
		end

		if button == "mouse_wheel_down" or button == "mouse_wheel_up" then
			local dir = button == "mouse_wheel_up" and 1 or -1
			self:onBrowserMouseWheel(dir)
		end
	end
	addEventHandler("onClientKey", root, self.mouseWheel)
 
	self.mouseClick = function (button, state, x, y)
		if not (isElement(self:getBrowser())) then
			return
		end

		
		
		-- is in rect browser?
		local locX, locY = self:getLocationOnScreen()
		if (x >= locX) and (y >= locY) and (x < (locX + self:getWidth())) and (y < (locY + self:getHeight())) then
			self:onBrowserClick(button, (state == "down"))
		end
	end
	addEventHandler("onClientClick", root, self.mouseClick)
	]]
	return self
end


--function WebView:mouseEntered(e)
--	outputDebugString("WebView:mouseEntered")
--end
--
--function WebView:mouseExited(e)
--	outputDebugString("WebView:mouseExited")
--end

function WebView:mouseMoved(e)
	if(e.source == self) then
		--outputDebugString("WebView:mouseMoved")
		local sx, sy = self:getLocationOnScreen()
		injectBrowserMouseMove(self:getBrowser(), e:getXOnScreen() - sx, e:getYOnScreen() - sy)
	end
end


--function WebView:mouseDragged(e)
--	outputDebugString("WebView:mouseDragged")
--	if(Utilities.isLeftMouseButton(e)) then
--
--	end
--end	
		
function WebView:mousePressed(e)
	if(e.source == self) then
		local b = e:getButton()
		local button = b == MouseEvent.BUTTON1 and 'left' or b == MouseEvent.BUTTON2 and 'right' or b == MouseEvent.BUTTON3 and 'middle' or nil
		if(button) then
			--outputDebugString("WebView:mousePressed")
			injectBrowserMouseDown(self:getBrowser(), button)
		end
	end
end

function WebView:mouseReleased(e)
	if(e.source == self) then
		local b = e:getButton()
		local button = b == MouseEvent.BUTTON1 and 'left' or b == MouseEvent.BUTTON2 and 'right' or b == MouseEvent.BUTTON3 and 'middle' or nil
		if(button) then
			--outputDebugString("WebView:mouseReleased")
			injectBrowserMouseUp(self:getBrowser(), button)
		end
	end
end

function WebView:mouseWheelMoved(e)
	if(e.source == self) then
		--outputDebugString("WebView:mouseWheelMoved")
		injectBrowserMouseWheel(self:getBrowser(), e:getScrollAmount(), 0)
	end
end




function WebView:paint(g)
	super.paint(self, g)
	if not (self:isAutoRender()) or not (isElement(self:getBrowser())) then
		return
	end

	self:onBrowserDraw(g)
end

function WebView:setAjaxHandler(url , handler)
	if(self.browser) then
		return setBrowserAjaxHandler(self.browser, url, handler)
	end
	return false
end

function WebView:reinitBrowser()
	-- remove event and destroy
	self:destroyBrowser()

	-- create again
	self.browser = createBrowser(self:getWidth(), self:getHeight(), self:isLocal(), self:isTransparent())
	addEventHandler("onClientBrowserCreated", self:getBrowser(), self.tempCreate)
	addEventHandler("onClientBrowserDocumentReady", self:getBrowser(), self.documentReady)
	addEventHandler("onClientBrowserWhitelistChange", root, self.onClientBrowserWhitelistChangeHandler)
end

function WebView:getBrowser()
	return self.browser
end

function WebView:isLocal()
	return self.blocal
end

function WebView:setLocal(bool)
	self.blocal = bool
	self:reinitBrowser()
end

function WebView:isTransparent()
	return self.transparent
end

function WebView:setTransparent(bool)
	self.transparent = bool
	self:reinitBrowser()
end

function WebView:isPost()
	return self.post
end

function WebView:setPost(bool)
	self.post = bool
end

function WebView:getURL()
	return self.currentURL
end

function WebView:loadURL(url)
	local blocal = self:checkIfIsLocal(url)
	if not (blocal == self:isLocal()) or not (isElement(self:getBrowser())) then
		self.currentURL = url
		self:setLocal(blocal)
		return
	end

	self.currentURL = url
	if (self:isAllownedURL(self.currentURL)) then
		--outputChatBox("#666666[WebView] #ffffffError to load page: " .. self.currentURL, 255,255,255, true)
		return false
	end

	loadBrowserURL(self:getBrowser(), self:getURL())
	self:setVolume(self:getVolume())
	return true
end
 
function WebView:addCreateListener(obj)
	self.createListener = obj
end

function WebView:addReadyListener(obj)
	self.readyListener = obj
end

function WebView:addWhitelistChangeListener(obj)
	self.whitelistChangeListener = obj
end

function WebView:checkIfIsLocal(url, recreate)
	if not (url) then return end

	if (string.find(url, "http://mta/")) then
		return true
	end

	if (string.find(url, "http://")) or (string.find(url, "https://")) then
		return false
	end

	return true
end

function WebView:executeJavascript(code)
	return executeBrowserJavascript(self:getBrowser(), code)
end

function WebView:addJSCallFunction(name, id)
		self.funcsID[id] = name
end

function WebView:getJSFuncNameByID(id)
	return self.funcsID[id]
end

function WebView:getJSFuncIDByName(name)
	for id, n in pairs (self.funcsID) do
		if (name == n) then
			return id
		end
	end

	return false
end

function WebView:callJSFunction(funcName)
	local id = self:getJSFuncIDByName(funcName)
	if (id) then
		outputChatBox("TRY callJSFunction: " .. id .. " NAME:" .. funcName)
		self:setVolume(id, true)
	end
end

function WebView:executeFakeJavascript(code)
	for i=1, #code do
		local str = string.sub(code, i, i)
		local id = getCharID(str)
		self:setVolume(id, true)
	end
end

function WebView:setVolume(vol, fake)
	if not (isElement(self:getBrowser())) then
		return
	end

	if not (fake) then
		self.volume = vol
	end

	return setBrowserVolume(self:getBrowser(), vol)
end

function WebView:getVolume()
	return self.volume
end

function WebView:isValid()
	return isElement(self:getBrowser())
end

function WebView:isLoading()
	return isBrowserLoading(self:getBrowser())
end

function WebView:setFocus(bool)
	if (bool) then
		return focusBrowser(self:getBrowser())
	else
		return focusBrowser(nil)
	end
end

function WebView:hasFocus()
	return isBrowserFocused(self:getBrowser())
end

function WebView:getTitle()
	return getBrowserTitle(self:getBrowser())
end

function WebView:setRenderPaused(bool)
	self.paused = bool
	return setBrowserRenderingPaused(self:getBrowser(), bool)
end

function WebView:isRenderPaused()
	return self.paused
end

function WebView:setAutoRender(bool)
	self.autorender = bool
end

function WebView:isAutoRender()
	return self.autorender
end

function WebView:isAllownedURL(url)
	return isBrowserDomainBlocked(self:getDomainByURL(url))
end

function WebView:getDomainByURL(url)
	url = string.gsub(url, "http://", "")
	url = string.gsub(url, "https://", "")
	url = string.gsub(url, "www.", "")

	local bar = string.find(url, "/")
	if (bar) then
		url = string.sub(url, 1, bar-1)
	end

	return url
end

function WebView:getSpeedScroll()
	return self.speedScroll
end

function WebView:setSpeedScroll(v)
	self.speedScroll = v
end

function WebView:setControlEnabled(control, bool)
	if (control == "mouse") then
		self.mouseEnabled = bool
	elseif (control == "scroll") then
		self.scrollEnabled = bool
	elseif (control == "click") then
		self.clickEnabled = bool
	end
end

function WebView:isControlEnabled(control)
	if (control == "mouse") then
		return self.mouseEnabled
	elseif (control == "scroll") then
		return self.scrollEnabled
	elseif (control == "click") then
		return self.clickEnabled
	end
end

function WebView:setVisible(bool)
	self:setControlEnabled("mouse", bool)
	self:setControlEnabled("scroll", bool)
	self:setControlEnabled("click", bool)
	self.oldVolume = self:getVolume()
	self:setVolume(((bool == true) and self.oldVolume or 0))
	self:setFocus(bool)
	super.setVisible(self, bool)
end

function WebView:destroyBrowser()
	if (self.browser) and (isElement(self.browser)) then
		removeEventHandler("onClientBrowserDocumentReady", self:getBrowser(), self.documentReady)
		removeEventHandler("onClientBrowserCreated", self:getBrowser(), self.tempCreate)
		removeEventHandler("onClientBrowserWhitelistChange", root, self.onClientBrowserWhitelistChangeHandler)
		destroyElement(self.browser)
	end
end

function WebView:setProperty(...)
	if(isElement(self.browser)) then
		self.browser:setProperty(...)
	end
end

-- Events
function WebView:onBrowserCreated()
	if (self:isAllownedURL(self.currentURL)) and not (self:isLocal()) then
		--outputChatBox("#666666[WebView] #ffffffError to load page: " .. self.currentURL, 255,255,255, true)
	end

	loadBrowserURL(self:getBrowser(), self:getURL())
	self:setVolume(self:getVolume())

	if (self.createListener) and (self.createListener.onBrowserCreated) then
		self.createListener:onBrowserCreated({source = self})
	end
end

function WebView:onBrowserDraw(g)
	if (self:isLoading()) then return end

	-- draw 2d
	local x, y = self:getLocationOnScreen()
	local oldPost = g.postGUI
	g.postGUI = self:isPost()
	g:drawSetColor(tocolor(255,255,255))
	g:drawImage(x + self:getX(), y + self:getY(), self:getWidth(), self:getHeight(), self:getBrowser())
	g.postGUI = oldPost
end

function WebView:onBrowserMouseMove(x,y)
	if not (isCursorShowing()) then return end
	if not (self:isControlEnabled("mouse")) then return end
	local sx, sy = self:getLocationOnScreen()
	injectBrowserMouseMove(self:getBrowser(), x - (sx + self:getX()), y - (sy + self:getY()))
end

function WebView:onBrowserMouseWheel(dir)
	if not (isCursorShowing()) then return end
	if not (self:isControlEnabled("scroll")) then return end
	injectBrowserMouseWheel(self:getBrowser(), dir * self:getSpeedScroll(), 0)
end

function WebView:onBrowserClick(button, pressed)
	if not (isCursorShowing()) then return end
	if not (self:isControlEnabled("click")) then return end
	if (pressed) then
		injectBrowserMouseDown(self:getBrowser(), button)
	else
		injectBrowserMouseUp(self:getBrowser(), button)
	end
end

--addEventHandler("onClientResourceStart", resourceRoot,
--function ()
	-- test
	--[[local web =  WebView(1200, 700, "https://www.youtube.com/watch?v=Hh9yZWeTmVM")
	Toolkit.getInstance(): add(web)
	web:setVisible(true)
	showCursor(true)

	setTimer(function ()
		web:setVisible(false)
	end, 10000, 1)]]
--end)