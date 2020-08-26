local super = Class("XMLLoader", LuaObject).getSuperclass()

function XMLLoader:init(xmlPath, rootContainer, controller)
	super.init(self)
	self.xmlPath = xmlPath
	self.rootContainer = rootContainer or nil
	self.controller = controller or rootContainer
	self.scriptEnv = {}
	return self
end

function XMLLoader:setRoot(rootContainer)
	self.rootContainer = rootContainer
end

function XMLLoader:getRoot()
	return self.rootContainer
end

function XMLLoader:setController(controller)
	self.controller = controller
end

function XMLLoader:getController()
	return self.controller
end

function XMLLoader:load()
	local xmlRootNode = xmlLoadFile(self.xmlPath)
	if(xmlRootNode) then
		local component = self:loadNode(xmlRootNode, self.rootContainer)
		xmlUnloadFile(xmlRootNode)
		return component
	end
	return false
end

function XMLLoader:loadNode(xmlRootNode, parentComponent)
	local container = self:parseNode(xmlRootNode, parentComponent)
	local childrenNode = xmlFindChild(xmlRootNode, 'children', 0)
	if(childrenNode) then
		local childrenTable = xmlNodeGetChildren(childrenNode)
		for i, xmlNode in ipairs(childrenTable) do
			local component = self:loadNode(xmlNode)
			if(component) then
				container:add(component)
			end
		end	
	end
	return container
end

function XMLLoader:parseNode(xmlNode, parentComponent)
	local nodeName = xmlNodeGetName(xmlNode)
	local componentName = string.lower(nodeName)
	 
	local layoutX = tonumber(xmlNodeGetAttribute(xmlNode, "layoutX")) or 0
	local layoutY = tonumber(xmlNodeGetAttribute(xmlNode, "layoutY")) or 0
	local prefWidth = tonumber(xmlNodeGetAttribute(xmlNode, "prefWidth")) or 100
	local prefHeight = tonumber(xmlNodeGetAttribute(xmlNode, "prefHeight")) or 20
	local text = xmlNodeGetAttribute(xmlNode, "text") or ""
	local componentId = xmlNodeGetAttribute(xmlNode, "fx:id") or ""
	
	local styleNode = xmlFindChild(xmlNode, 'style', 0)
	if(styleNode) then
		self:parseNode(styleNode, parentComponent)
	end	
	
	local scriptNode = xmlFindChild(xmlNode, 'script', 0)
	if(scriptNode) then
		self:parseNode(scriptNode, parentComponent)
	end	
	
	local component = nil
	if(componentName == "nop") then
	elseif(componentName == "script") then
		
		local code = xmlNodeGetValue(xmlNode)
		local chunk = loadstring(code)
		if(chunk) then
			local selfObject = {}
			self.scriptEnv.self = self:getController()
			setfenv(chunk, setmetatable(self.scriptEnv, { __index = _G })) 
			chunk()
			--local controller = self:getController()
			--setfenv(chunk, _G) 		
			--outputDebugString(self.scriptEnv.teste)
			--getfenv(chunk)['handleButtonAction']({})
		end
		--[[
		--------------
		var1 = "Hello" 
		local function one() 
		  local var2 = "world" 
		  local code = "outputChatBox(var1 .. var2)" 
		  chunk = loadstring(code) 
		  local locals = { var2 = var2, } 
		  setfenv(chunk, setmetatable(locals, { __index = _G })) 
		  chunk() 
		end 

		one() 
		]]
		
	elseif(componentName == "style") then
		local css = xmlNodeGetValue(xmlNode)
		Graphics.getInstance():setStylesheet(StylesheetParser():parsestr(css))
	elseif(componentName == "anchorpane") then
		component = parentComponent
	elseif(componentName == "pane") then
		component = Panel()
		local foreground = xmlNodeGetAttribute(xmlNode, "foreground")
		if foreground then component:setForeground(tocolor(getColorFromString(foreground))) end
		local background = xmlNodeGetAttribute(xmlNode, "background")
		if background then component:setBackground(tocolor(getColorFromString(background))) end
	elseif(componentName == "label") then	
		component = Label()
		component:setText(text)
		component:setForeground(tocolor(getColorFromString(xmlNodeGetAttribute(xmlNode, "textFill"))))
		component:setBackground(tocolor(0,0,0,0))
	elseif(componentName == "button") then	
		component = Button(text)
		component:setActionCommand(componentId)
		
		local locator, handlerName = XMLLoader.getHandler(xmlNodeGetAttribute(xmlNode, "onAction"))
		if(locator == "controller") then
			local controller = self:getController()
			local handler = controller[handlerName]
			component:addActionListener({
				actionPerformed = function(e)
					handler(controller, e)
				end
			})
		else
			local controller = self:getController()
			local handler = self.scriptEnv[handlerName]
			component:addActionListener({
				actionPerformed = function(e)
					handler(e)
				end
			})
		end
	elseif(componentName == "textfield") then	
		component = TextField()
		component:setText(text)
	elseif(componentName == "passwordfield") then	
		component = PasswordField()
		component:setText(text)		
	end
	if(component) then
		
		if(componentId) then
			component:setId(componentId)
			self.scriptEnv.self[componentId] = component
		end	
		--component:setForeground(tocolor(math.random(255),math.random(255),math.random(255)))
		--component:setBackground(tocolor(math.random(255),math.random(255),math.random(255)))
		component:setBounds(layoutX, layoutY, prefWidth, prefHeight)
	end
	

	
	return component
end


function XMLLoader.getHandler(text)
	local locator = string.sub(text, 1, 1)
	if(locator == "#") then
		return "controller", string.sub(text, 2)
	else
		return "default", string.sub(text, 1)
	end
end

