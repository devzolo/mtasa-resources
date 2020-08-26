local super = Class("CountdownHud", Container, function()
	static.getInstance = function()
		return LuaObject.getSingleton(static)
	end
end).getSuperclass()

function CountdownHud:init()
	super.init(self)

	self.decorator = true

	self:setBounds(0, 0, Graphics.getInstance():getWidth(), Graphics.getInstance():getHeight())

	local x = Graphics.relativeW(400)
	local y = Graphics.relativeH(150)
	local w = Graphics.relativeH(100)
	local h = Graphics.relativeH(100)

	self.container = Container()
	self.container:setBounds(x-w/2,y-h/2,w,h)
	self:add(self.container)

	self.defaultY = self.container:getY()

	self.label = Label()
	self.label:setBounds(0, 0, self.container:getWidth(), self.container:getHeight())
	self.label:setForeground(tocolor(255,255,255))
	self.label:setBackground(tocolor(0,0,0))
	self.label:setScale(Graphics.relativeH(1.0) * 2.8)
	self.label:setFont("pricedown")
	self.label:setText("3")
	self.label:setAlignment(Label.CENTER)
	self.label.decorator = true
	self.container:add(self.label)
	return self
end

function CountdownHud:paint(g)
	self.floatCount = self.floatCount - getFrameTime() / 1000
	local count = math.floor(self.floatCount)
	if(self.count ~= count) then
		if(count < -1) then
			self:setVisible(false)
		elseif(count > 0) then
			self.label:setText(tostring(count))
			playSFX("genrl", 52, 6, false)
		elseif(count == 0) then
			self.label:setText("GO")
			playSFX("genrl", 52, 13, false)
		end
		self.count = count
	end

	local progress = math.max(math.abs(math.fmod(self.floatCount - count, 1.0)), 0)
	local alpha = iif(count == 0, 255, math.floor(255 * progress))
	if(count > 0) then
		self:setBackground(210, 173, 85, alpha)
	elseif(count <= 0) then
		self:setBackground(100, 145, 100, alpha)
		if(count == -1) then
			self.container:setLocation(self.container:getX(), interpolateBetween( self.defaultY, 0, 0, -self.container:getHeight(), 0,  0, 1.0-progress, "Linear"))
		end
	end

	g:drawSetColor(self:getBackground())
	g:fillOval(self.container:getX() + self.container:getWidth()/2, self.container:getY() + self.container:getHeight()/2, self.container:getWidth(), self.container:getHeight(), self.circleColor)
	super.paint(self, g)
end

function CountdownHud:setCount(count)
	self.count = count + 1
	self.floatCount = self.count
	self.container:setLocation(self.container:getX(), self.defaultY)
end

function CountdownHud:setVisible(visible)
	if(visible) then
		Toolkit.getInstance():add(self)
	else
		Toolkit.getInstance():remove(self)
	end
	super.setVisible(self,visible)
end

function displayRaceCountdown(seconds)
	local countdown = CountdownHud.getInstance()
	countdown:setCount(seconds)
	countdown:setVisible(true)
end


addCommandHandler("count", function()
	displayRaceCountdown(3)
end)
