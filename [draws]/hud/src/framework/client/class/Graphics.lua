local super = Class("Graphics", Container).getSuperclass()

Graphics.viewPortX = 0
Graphics.viewPortY = 0

function Graphics.getInstance()
	return LuaObject.getSingleton("Graphics")
end

function Graphics:init()
	super.init(self)

	self.width, self.height = guiGetScreenSize()

	self.bufferedPolygons = {}

	self.textX = 0
	self.textX = 0
	self.font = "default"
	self.scale = 1
	self.postGUI = false
	self.textW = 800
	self.textH = 600
	self.lineWidth = 1

	self.onRender = function()
		super.paint(self, self)
	end

	--self:setFocusCycleRoot(true)
	return self
end

function Graphics.relativeW(w)
	return (Graphics.getInstance():getWidth()/800)*(w)
end

function Graphics.relativeH(h)
	return (Graphics.getInstance():getHeight()/600)*(h)
end

function Graphics.getInsets(x,y,w,h)
	return Graphics.relativeW(x),Graphics.relativeH(y),Graphics.relativeW(w),Graphics.relativeH(h)
end

-- rendering functions
function Graphics:drawSetColor(r, g, b, a)
	if(g and b) then
		self.color = tocolor(r, g, b, a)
	else
		self.color = r
	end
end

function Graphics:fillOval(x, y, width, height)
  --dxDrawCircle(Graphics.viewPortX + x, Graphics.viewPortY + y, width, height, self.color)
  --dxDrawCircle ( float posX, float posY, float radius [, float startAngle = 0.0, float stopAngle = 360.0, int theColor = white, int theCenterColor = theColor, int segments = 32, int ratio = 1, bool postGUI = false ] )
  dxDrawCircle(Graphics.viewPortX + x, Graphics.viewPortY + y, height/2, 0.0, 360.0, self.color, self.color, 32, width / height, postGUI)
end

function Graphics:drawFilledRect(startX, startY, width, height)
	dxDrawRectangle(Graphics.viewPortX + startX, Graphics.viewPortY + startY, width, height, self.color, postGUI)
end

function Graphics:drawSetLineWidth(w)
	self.lineWidth = w
end

function Graphics:drawLine(startX, startY, endX, endY)
	dxDrawLine(Graphics.viewPortX + startX, Graphics.viewPortY + startY, Graphics.viewPortX + endX, Graphics.viewPortY + endY, self.color, self.lineWidth or 1, postGUI)
end

function Graphics.getRealFontHeight(font)
    local cap,base = Graphics.measureGlyph(font, "S")
    local median,decend = Graphics.measureGlyph(font, "p")
    local ascend,base2 = Graphics.measureGlyph(font, "h")

    local ascenderSize = median - ascend
    local capsSize = median - cap
    local xHeight = base - median
    local decenderSize = decend - base

    return math.max(capsSize, ascenderSize) + xHeight + decenderSize
end

function Graphics.measureGlyph(font, character)
    local rt = dxCreateRenderTarget(128,128)
    dxSetRenderTarget(rt,true)
    dxDrawText(character,0,0,0,0,tocolor(255,255,255),1,font)
    dxSetRenderTarget()
    local pixels = dxGetTexturePixels(rt)
    local first,last = 127,0
    for y=0,127 do
        for x=0,127 do
            local r = dxGetPixelColor( pixels,x,y )
            if r > 0 then
                first = math.min( first, y )
                last = math.max( last, y )
                break
            end
        end
        if last > 0 and y > last+2 then break end
    end
    destroyElement(rt)
    return first,last
end

function Graphics.getFontSizeFromHeight( height, font )
    if type( height ) ~= "number" then return false end
    font = font or "default"
    local ch = dxGetFontHeight( 1, font )
    return height/ch
end

function Graphics:drawCircle(posX, posY, radius, width, angleAmount, startAngle, stopAngle, color, postGUI)
	if ( type( posX ) ~= "number" ) or ( type( posY ) ~= "number" ) then
		return false
	end

	local function clamp( val, lower, upper )
		if ( lower > upper ) then lower, upper = upper, lower end
		return math.max( lower, math.min( upper, val ) )
	end

	radius = type( radius ) == "number" and radius or 50
	width = type( width ) == "number" and width or 5
	angleAmount = type( angleAmount ) == "number" and angleAmount or 1
	startAngle = clamp( type( startAngle ) == "number" and startAngle or 0, 0, 360 )
	stopAngle = clamp( type( stopAngle ) == "number" and stopAngle or 360, 0, 360 )
	color = color or tocolor( 255, 255, 255, 200 )
	postGUI = type( postGUI ) == "boolean" and postGUI or false

	if ( stopAngle < startAngle ) then
		local tempAngle = stopAngle
		stopAngle = startAngle
		startAngle = tempAngle
	end

	for i = startAngle, stopAngle, angleAmount do
		local startX = math.cos( math.rad( i ) ) * ( radius - width )
		local startY = math.sin( math.rad( i ) ) * ( radius - width )
		local endX = math.cos( math.rad( i ) ) * ( radius + width )
		local endY = math.sin( math.rad( i ) ) * ( radius + width )

		dxDrawLine( startX + posX, startY + posY, endX + posX, endY + posY, color, width, postGUI )
	end

	return true
end
function pnpoly(nvert, vertx, verty, testx, testy)
	local i = 1
	local j = nvert
	local c = false
	while(i <= nvert) do
		if ( ((verty[i]>testy) ~= (verty[j]>testy)) and (testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) ) then
			c = not c
		end
		j = i
		i = i + 1
	end
	return c
end

function Graphics:drawPolygon(sx,sy,points)
	local key = toJSON(points)

	if(not isElement(self.bufferedPolygons[key])) then
		self.bufferedPolygons[key] = dxCreateTexture (self.width, self.height, "argb", "wrap", "2d", 1)

		local pixels = dxGetTexturePixels (0, self.bufferedPolygons[key])
		local vertx = {}
		local verty = {}
		local i = 1
		while(i < #points) do
			table.insert(vertx, points[i])
			table.insert(verty, points[i+1])
			i = i + 2
		end
		local nvert = #vertx

		for x = 1, self.width do
			for y = 1, self.height do
				if(pnpoly(nvert,vertx,verty,x,y)) then
					dxSetPixelColor(pixels, x, y,255, 255, 255, 255)
				end
			end
		end
		dxSetTexturePixels(0, self.bufferedPolygons[key], pixels)
	end

	dxDrawImage(Graphics.viewPortX + sx, Graphics.viewPortY +sy, self.width, self.height, self.bufferedPolygons[key], 0, 0, 0, self.color, self.postGUI)

end

function Graphics:drawSetTextFont(font)
	self.font = font
end

function Graphics:drawSetTextColor(r, g, b, a)
	if(g and b) then
		self.textColor = tocolor(r, g, b, a)
	else
		self.textColor = r
	end
end

function Graphics:drawSetTextScale(scale)
	self.scale = scale
end
function Graphics:drawGetTextScale()
	return self.scale
end

function Graphics:drawSetTextPos(x,y)
	self.textX, self.textY = x, y
end

function Graphics:drawGetTextPos()
	return self.textX, self.textY
end

function Graphics:drawSetTextBounds(x,y,w,h)
	self.textX, self.textY, self.textW, self.textH = x, y, w, h
end

function Graphics:drawGetTextBounds()
	return self.textX, self.textY, self.textW, self.textH
end

function Graphics:drawSetTextClip(clip)
	self.textClip = clip
end

function Graphics:drawSetColorCoded(colorCoded)
	self.colorCoded = colorCoded
end

function Graphics:drawSetSubPixelPositioning(subPixelPositioning)
	self.subPixelPositioning = subPixelPositioning
end

function Graphics:drawSetTextWordBreak(wordBreak)
	self.textWordBreak = wordBreak
end



function Graphics:drawPrintText(text, textLen)
	dxDrawText(text or ""
		 , Graphics.viewPortX + self.textX
		 , Graphics.viewPortY + self.textY
		 , self.textW or 800
		 , self.textH or 600
		 , self.textColor or tocolor(255,255,255)
		 , self.scale or 1
		 , self.font or "default"
	   , self.textAlignX or "left"
		 , self.textAlignY or "top"
		 , self.textClip or false
		 , self.textWordBreak or false
		 , self.postGUI or false
		 , self.colorCoded or false
     , self.subPixelPositioning or false)
end

function Graphics:getFontHeight(font)
	return dxGetFontHeight(self.scale, font or self.font)
end

function Graphics:getTextSize(font,text)
	return dxGetTextWidth(text or "", self.scale, font or self.font or "default"), dxGetFontHeight(self.scale, font or self.font or "default")
end


function Graphics:getPossibleTextSize(font, text, testw, reverse)
	local size = 0.0
	local oldsize = 0.0
	local len = 0
	--outputDebugString(string.format("text:utfLen() = %d", text:utfLen()))
	--outputDebugString(string.format("text:utfSub() = %s", string.sub(text, 2, 2)))
	if(text) then
		if(not reverse) then
			local tlen = text:utfLen()
			for i=1, tlen do
				oldsize = size
				size = size + self:getTextSize(font, text:utfSub(i, i))
				if(size  > testw) then
					return i-1, oldsize
				else
					len = i
				end
			end
		else
			local tlen = text:utfLen()
			local pos = 0
			local j = 1
			for i=0, tlen-1 do
				oldsize = size
				pos = tlen - i
				size = size + self:getTextSize(font, text:utfSub(pos, pos))
				if(size  > testw) then
					return j, oldsize
				else
					len = j
				end
				j = j +  1
			end
		end
	end
	return len, size
end

function Graphics:drawImage(x,y,width,height, source, angle, rotationCenterOffsetX, rotationCenterOffsetY)
	dxDrawImage(Graphics.viewPortX + x, Graphics.viewPortY + y, width, height, source, angle or 0, rotationCenterOffsetX or 0, rotationCenterOffsetY or 0, self.color, self.postGUI)
end

function Graphics:drawImageSection(x,y,width,height, u, v, usize, vsize, source, angle, rotationCenterOffsetX, rotationCenterOffsetY)
	dxDrawImageSection(Graphics.viewPortX + x, Graphics.viewPortY + y, width, height, u, v, usize, vsize, source, angle, rotationCenterOffsetX, rotationCenterOffsetY, self.color, self.postGUI)
end

--function Graphics:getScreenSize()
--	return self.width, self.height
--end

function Graphics:getScreenSize()
	if(self.screenSize == nil) then
		self.screenSize = Dimension(self.width, self.height)
	end
	return self.screenSize
end

function Graphics:add(comp)
	if(comp) then
		if(self.components:isEmpty()) then
			if(not isEventHandlerAdded("onClientRender", root, self.onRender)) then
				addEventHandler("onClientRender", root, self.onRender, true, "low")
			end
		end
		super.add(self, comp)
	end
end

function Graphics:remove(comp)
	if(comp and comp.parent == self) then
		super.remove(self, comp)
		if(self.components:isEmpty()) then
			if(isEventHandlerAdded("onClientRender", root, self.onRender)) then
				removeEventHandler("onClientRender", root, self.onRender)
			end
		end
	end
end

function Graphics:isDisplayable()
	return false
end

