local super = Class("HTML", Container).getSuperclass()

HTML.fontCache = {}
HTML.textureCache = {} 
HTML.textureWaiter = {} 
HTML.labelAlignTypes = {
	["left"] = Label.LEFT,
	["center"] = Label.CENTER,
	["right"] = Label.RIGHT
}

function HTML.getTexture(name)
	if(HTML.textureCache[name] ~= nil) then
		return HTML.textureCache[name]	
	end	
	return nil
end

function HTML.addTexture(name, pixels)
	if(HTML.textureCache[name] == nil) then
		HTML.textureCache[name] = dxCreateTexture (pixels, "argb", true, "wrap")	
	end	
	return HTML.textureCache[name]
end

function HTML.addImageRequest(name, component, w, h)
	local texture = HTML.getTexture(name)
	if(texture) then
		if(component) then
			component:setSource(texture)	
		end
	else
		if(component) then
			HTML.textureWaiter[name] = HTML.textureWaiter[name] or {}
			table.insert(HTML.textureWaiter[name], component)
			component.loading = true
			triggerEvent("doWebImageRequest", localPlayer, name, w or 100, h or 100)
		end
	end
end


local HTTP_IMAGE_URL = "http://167.114.24.72:8080/mta/plugins/img/img.php"
--local HTTP_IMAGE_URL = "http://localhost/mta/plugins/img/img.php"


function webRequest(url, clientUrl, ...)
	if(url) then
		--bool fetchRemote ( string URL[, int connectionAttempts = 10 ], callback callbackFunction, [ string postData = "", bool postIsBinary = false, [ arguments... ] ] )
		fetchRemote(url, 10, webRequestCallback, "", false, sendTo, clientUrl)
		--outputDebugString("fetchRemote called...")
		--outputDebugString(url)
	end
end

function webImageRequest(clientUrl, w, h, ...)
	local url = HTTP_IMAGE_URL .. "?src=" .. clientUrl .. "&w=" .. (w or "200") .. "&h=" ..  (h or "200")
	webRequest(url, clientUrl)
end

function webRequestCallback(responseData, errno, sendTo, clientUrl)
	outputDebugString("errno = " .. errno)
    if errno == 0 then
		triggerEvent("onClientWebResponse", root, clientUrl, responseData)
    end
end

function doWebImageRequest(clientUrl, w, h)
	webImageRequest(clientUrl, w, h)
end
addEvent("doWebImageRequest")
addEventHandler("doWebImageRequest", root, doWebImageRequest)



function HTML.updateResponseImage(name, pixels)
	texture = HTML.addTexture(name, pixels)
	for _,component in pairs(HTML.textureWaiter[name] or {}) do
		component:setSource(texture)
	end
	HTML.textureWaiter[name] = nil
end

function HTML.getFont(name)
	if(fileExists(name)) then
		if(HTML.fontCache[name] == nil) then
			HTML.fontCache[name] = dxCreateFont(name, 10)
		end
		return HTML.fontCache[name]
	end
	return name
end

function dectohex(IN)
    local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),math.mod(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end
	if(OUT and string.len(OUT) == 1) then
		OUT = "0" .. OUT
	end
	if(OUT == "") then
		return "00"
	end
    return OUT
end

rgb = function(r,g,b)
	return "#" .. dectohex(r) .. dectohex(g) .. dectohex(b) 
end

string.lpad = function(str, len, char)
	local tmp = tostring(str)
    if char == nil then char = ' ' end
    return tmp .. string.rep(char, len - #tmp)
end

function HTML:init(sourceWidth, sourceHeight)
	super.init(self)
	self.clear = true
	self.viewX = 0
	self.viewY = 0
	self.oldViewX = -1
	self.oldViewY = -1
	self.viewPortWidth = 0
	self.viewPortHeight = 0	
	self.valid = false
	self.fontSize = 1
	self.labelPrefix = ""
	self.labelAlign = "left"
	self.fontColor = "#FFFFFF"
	self.elements = {}
	self.elementsById = {}
	self.document = {
		getElementById = function(_,id)
			return self.elementsById[id]
		end,
		body = {
			append = function(...)
				self.docTree = {
				  _tag = "#document",
				  _attr = {},
				  {
					_tag = "html",
					_attr = {},
					{
					  _tag = "body",
					  _attr = {},
					  ...,
					}
				  }
				}
				self:refreshDocument()	
			end			
		},
		load = function(file,p)
			_params = p or {}
			self:setContentPage(file)
		end,			
		reload = function(_)
			self:refreshDocument()
		end,
		createElement = function(tag, attr, ...)
			local args = {...}
			local element = {
				_tag = tag,
				_attr = attr,
				...,
				append = function(self, obj)
					table.insert(self, obj)
				end
			}
			return element
		end,		
	}

	self:setAutoUpdate(true)
	self:setSourceSize(sourceWidth, sourceHeight)
	super.addMouseWheelListener(self,self)
	return self
end

function HTML:setSourceSize(sourceWidth, sourceHeight)
	if(sourceWidth == nil) then
		sourceWidth = Graphics.getInstance():getWidth()
	end
	if(sourceHeight == nil) then
		sourceHeight = Graphics.getInstance():getHeight()
	end

	self.sourceWidth, self.sourceHeight = sourceWidth, sourceHeight
	if(self.HTML) then
		destroyElement(self.HTML)
	end
	self.HTML = dxCreateRenderTarget(self.sourceWidth, self.sourceHeight, true) 
end

function HTML:setAutoUpdate(value)
	self.autoUpdate = value
end

function HTML:setWindow(window)
	self.window = window
end

function HTML:paint(g)
	local x, y = self:getLocationOnScreen()
	local w = self:getWidth()
	local h = self:getHeight()
	
	--g:drawSetColor( self:getBackground() );
	--g:drawFilledRect(x,   y,   w, 1);
	--g:drawFilledRect(x+w, y,   1, h);
	--g:drawFilledRect(x,   y,   1, h);
	--g:drawFilledRect(x,   y+h, w, 1);	
	
	if(self.autoUpdate) then
		if(not self.valid or self.viewX ~= self.oldViewX or self.viewY ~= self.oldViewY) then
			self.valid = true
			self.oldViewX = self.viewX
			self.oldViewY = self.viewY
			Graphics.viewPortX = self.viewX
			Graphics.viewPortY = self.viewY
			dxSetRenderTarget(self.HTML, self.clear)
			self.paintingComponents = true
			super.paintComponent(self,g)
			self.paintingComponents = false
			dxSetRenderTarget()
			Graphics.viewPortX = 0
			Graphics.viewPortY = 0
		end
	end
	
	if self.HTML then
		dxDrawImage(x, y, w, h, self.HTML)
	end
end

function HTML:getX()
	if(self.paintingComponents) then return 0 end
	return self.x
end

function HTML:getY()
	if(self.paintingComponents) then return 0 end
	return self.y
end

function HTML:addLabel(content)
	local text = content.text or ""
	local label = Label()
	label:setForeground(self.fontColor)
	label:setBackground(tocolor(0,0,0))
	label:setScale(Graphics.relativeW(self.fontSize))
	label:setText(self.labelPrefix .. text)
	label:setFont(HTML.getFont(self.fontFace) or "default")
	label:setAlignment(HTML.labelAlignTypes[self.labelAlign])
	local x = self.componetAddPosX
	local y = self.componetAddPosY
	local w = label:getTextWidth()--self:getWidth()
	local h = label:getTextHeight()
	if(self.centerAlign) then
		x = self:getWidth()/2 - w/2
	end	
	label:setBounds(x, y, w, h)
	 
	--label:setBounds(self.componetAddPosX, self.componetAddPosY, 500, label:getContentHeight())	
	label:setClip(true)
	label:setWordBreak(true)
	label:setColorCoded(true)
	self.elements[#self.elements+1] =  label
	self:add(label)	
	
	if(content._attr) then	
		if(content._attr.id) then
			self.elementsById[content._attr.id] = label
		end
	end
	
	if(content._params) then
		label._params = content._params	
	end		
	
	if(self.href or self.onclick or self.onmouseover or self.onmouseout) then
		label.href = self.href or "#"
		label.onclick = self.onclick
		label.onmouseover = self.onmouseover
		label.onmouseout = self.onmouseout
		label:addMouseListener(self)
	end
	label:addMouseWheelListener(self)
	
	if(self.contentType == "text/plain") then
		self.componetAddPosY = self.componetAddPosY + label:getContentHeight()	
	elseif(self.contentType == "text/html") then
		self.componetAddPosY = self.componetAddPosY + label:getContentHeight() - label:getTextHeight()
	end
	
	self:updateViewPort(label)
end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function HTML:addImage(content)

	local image = Image()
	if(content._attr.src) then
		if(string.starts(content._attr.src,"http://") or string.starts(content._attr.src,"https://")) then
			HTML.addImageRequest(content._attr.src, image, tonumber(content._attr.width), tonumber(content._attr.height))
		else
			image:setSource(content._attr.src)
		end
	end
	
	local imgWidth = tonumber(content._attr.width) or image:getImageWidth()
	local imgHeight = tonumber(content._attr.height) or image:getImageHeight()	
	local x = self.componetAddPosX
	local y = self.componetAddPosY
	local w = Graphics.relativeW(imgWidth)
	local h = Graphics.relativeH(imgHeight)
	if(self.centerAlign) then
		x = self:getWidth()/2 - w/2
	end	
	image:setBounds(x, y, w, h)
	self.elements[#self.elements+1] =  image
		
	self:add(image)	
	image:addMouseWheelListener(self)
	--image:addMouseListener(self)
	
	self.componetAddPosY = self.componetAddPosY + image:getHeight()
	
	self:updateViewPort(image)
	
end

function HTML:updateViewPort(content)
	self.viewPortWidth = math.max(self.viewPortWidth, content:getX() + content:getWidth())
	self.viewPortHeight = math.max(self.viewPortHeight, content:getY() + content:getHeight())
	self.viewPortHeight = math.max(self.viewPortHeight, self.componetAddPosY)
end

function HTML:getViewY()
	return self.viewY 
end

function HTML:setViewY(viewY)
	self.viewY = viewY
end

function HTML:getTextHeight()
	return dxGetFontHeight(self.scale, self.font) 
end

function HTML:getContentHeight()
	return self.viewPortHeight
end

function HTML:getContentSize()
	return dxGetTextWidth(self.textClean, self.scale, self.font), self:getContentHeight()
end
 	
function HTML:setDocument(src)
	self.docTree = parsestr(src)
	self:refreshDocument()
end

function HTML:refreshDocument()
	for _, element in pairs(self.elements) do
		self:remove(element)
	end
	if(self.docTree) then
		self.componetAddPosX = 0 
		self.componetAddPosY = 0
		self.viewX = 0
		self.viewY = 0
		self.oldViewX = -1
		self.oldViewY = -1
		self.viewPortWidth = 0
		self.viewPortHeight = 0	
		if(self.docTree._tag == "#document") then
			self.contentType = "text/plain"
			for _, content in pairs(self.docTree) do
				if(type(content) == "table" and content._tag == "html") then
					self.contentType = "text/html"
					self:processContent(content)
				end
			end
			if(self.contentType == "text/plain") then
				self:addLabel({text=src,_attr={}})
			end
		end
	end	
	self.valid = false
end

function HTML:addHyperlinkListener(l)
	self.hyperlinkListener = l
end

function HTML:addContentParseListener(l)
	self.contentParseListener = l
end

function HTML:fireParse(e)
	local listener = self.contentParseListener
	if(listener)then
		if(listener.__index)then
			listener:contentParsed(e) 
		else
			listener.contentParsed(e) 
		end
	end	
end

function HTML:setContentPage(file)
	if(file == "#") then 
		return 
	end
	local hFile = fileOpen(file) 
	local content = ""
	if hFile then  
		local buffer
		while not fileIsEOF(hFile) do  
			buffer = fileRead(hFile, 500) 
			content = content .. buffer          
		end
		fileClose(hFile) 
		self:setDocument(content)
	else
		outputDebugString("Unable to open " .. file)
	end
end

function HTML:processContent(content)

	local attr = {
		fontColor = self.fontColor or false,
		labelAlign = content.labelAlign or self.labelAlign or "left",
		centerAlign = self.centerAlign or false,
		href = self.href or false,
		onclick = self.onclick or false,
		onmouseover = self.onmouseover or false,
		onmouseout = self.onmouseout or false,
	}   
	
	if(content._attr) then
		attr.id = content._attr.id or nil
		attr._params = content._attr._params
	end

	if(self.loadingScript) then
		local script = ""
		for _, content in pairs(content) do
			if(type(content) == "string" and trim(content) ~= "script") then
				script = script .. content	
			end
		end
		if(script) then
			--outputDebugString(trim(script))
			eval(trim(script))
		end
		return
	else
		local text = "" 
		for key, content in pairs(content) do
			if(type(content) == "string") then
				text = text .. trim(content)
			elseif(type(content) == "table") then
				if(key == "_params") then
					--self.currentParams = content or {}
				else
					if(text ~= nil and trim(px(text)) ~= "") then
						if(self.titleParse) then
							self:fireParse({tag = "title", text = text})
						else
							self:addLabel({text=text,_attr=attr,_params=attr._params})
						end
						--outputDebugString(text)
					end
					if(content._tag == "img") then
						self:addImage(content)
					elseif(content._tag == "font") then
						self.fontSize = content._attr.size or 1
						self.fontColor = content._attr.color or "#FFFFFF"
						self.fontFace = content._attr.face or "default"
						self:processContent(content)
						self.fontColor = attr.fontColor
						self.fontSize = 1
						self.fontFace = "default"
					elseif(content._tag == "br") then
						self.componetAddPosY = self.componetAddPosY + 15
						self:processContent(content)				
					elseif(content._tag == "center") then
						self.centerAlign = true
						self:processContent(content)	
						self.centerAlign = false
					elseif(content._tag == "script") then
						self.loadingScript = true
						self:processContent(content)	
						self.loadingScript = false
					elseif(content._tag == "head") then
						self:processContent(content)
					elseif(content._tag == "title") then
						self.titleParse = true
						self:processContent(content)	
						self.titleParse = false
					elseif(content._tag == "body") then
						self:processContent(content)
						if(content._attr.onload) then
							this = self.document
							document = self.document
							eval(content._attr.onload)
						end
					elseif(content._tag == "a") then
						self.href = content._attr.href or false
						self.onclick = content._attr.onclick or false
						self.onmouseover = content._attr.onmouseover or false
						self.onmouseout = content._attr.onmouseout or false
						self.fontColor = content._attr.color or "#FFFFFF"
						self:processContent(content)	
						self.href = attr.href		
						self.onclick = attr.onclick or false	
						self.onmouseover = attr.onmouseover or false
						self.onmouseout = attr.onmouseout or false	
						self.fontColor = attr.fontColor
					elseif(content._tag == "p") then
						self.labelAlign = content._attr.align or "left"
						self:processContent(content)
						self.labelAlign = attr.labelAlign	
					elseif(content._tag == "label") then
						self.labelAlign = content._attr.align or "left"
						self.id = attr.id or nil
						self:processContent(content)
						self.id = attr.id	
						self.labelAlign = attr.labelAlign				
					elseif(content._tag == "ul") then
						self:processContent(content)
					elseif(content._tag == "li") then
						self.labelPrefix = "● "
						self:processContent(content)	
						self.labelPrefix = ""	
					elseif(content._tag == "h1") then
						self.fontSize = 4.0
						self:processContent(content)
						self.fontSize = 1
					elseif(content._tag == "h2") then
						self.fontSize = 3.5
						self:processContent(content)
						self.fontSize = 1
					elseif(content._tag == "h3") then
						self.fontSize = 3.0
						self:processContent(content)
						self.fontSize = 1
					elseif(content._tag == "h4") then
						self.fontSize = 2.5
						self:processContent(content)
						self.fontSize = 1	
					elseif(content._tag == "h5") then
						self.fontSize = 2.0
						self:processContent(content)
						self.fontSize = 1	
					elseif(content._tag == "h6") then
						self.fontSize = 1.5
						self:processContent(content)
						self.fontSize = 1	
					else
						self:processContent(content)
					end	
				end
			end
		end
	end
end


function HTML:addMouseWheelListener(l)
	if (l == nil) then
		return
	end
	self.htmlMouseWheelListener = l
end

function HTML:mouseWheelMoved(e)
	local listener = self.htmlMouseWheelListener
	if(listener)then
		if(listener.__index)then
			listener:mouseWheelMoved(e) 
		else
			listener.mouseWheelMoved(e) 
		end
	end	
end

function HTML:mouseEntered(e)
	if(e.source.onmouseover) then
		this = e.source
		document = self.document
		local result = eval(e.source.onmouseover)
	end 
	self.valid = false
end

function HTML:mouseExited(e)
	if(e.source.onmouseout) then
		this = e.source
		document = self.document
		local result = eval(e.source.onmouseout)
	end 
	self.valid = false
end
 
function HTML:mousePressed(e)
	if(e.source.href) then
	
		local result = true
		
		if(e.source.onclick) then
			this = e.source
			document = self.document
			result = eval(e.source.onclick)
		end 
		
		if(result ~= false) then
			if(self.hyperlinkListener) then
				local listener = self.hyperlinkListener
				if(listener)then
					local href = e.source.href
					local event = {
						url = href,
						href = href,
					}
					if(listener.__index)then
						listener:hyperlinkUpdate(event) 
					else
						listener.hyperlinkUpdate(event) 
					end
				end
			end
		end
	end 
	self.valid = false
end

function HTML:mouseReleased(e)
	--outputDebugString("mouseReleased")
	self.valid = false
end

function HTML:mouseClicked(e)
	--outputDebugString("mouseClicked")
	self.valid = false
end