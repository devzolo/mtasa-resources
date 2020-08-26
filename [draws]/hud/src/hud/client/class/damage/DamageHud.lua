local super = Class("DamageHud", Container, function()
	static.getInstance = function()
		return LuaObject.getSingleton(static)
	end
end).getSuperclass()

function DamageHud:init()
	super.init(self)

	self.dw = Graphics.relativeW(128)
	self.dh = Graphics.relativeH(256)

	self:setBounds(Graphics.getInsets(0, 0, 800, 600))
	self:setBackground(tocolor(0,0,0,101))
	self:setForeground(tocolor(0,0,0,200))

	self.damageInd = Image()
	self.damageInd:setSource("gfx/hud/damage_ind.png")
	self.damageInd:setBounds(self:getWidth()/2 - self.dw/2,self:getHeight()/2 - self.dh/2, self.dw, self.dh)
	self.damageInd:setColor(tocolor(200,0,0,200))
	self:add(self.damageInd)
	return self
end

---------------------------------------------------------------------------
-- Camera functions
---------------------------------------------------------------------------
function DamageHud:getCameraRot()
	local px, py, pz, lx, ly, lz = getCameraMatrix()
	local rotz = math.atan2 ( ( lx - px ), ( ly - py ) )
 	local rotx = math.atan2 ( lz - pz, getDistanceBetweenPoints2D ( lx, ly, px, py ) )
 	return math.deg(rotx), 180, -math.deg(rotz)
end

---------------------------------------------------------------------------
-- Time functions
---------------------------------------------------------------------------
function DamageHud:getSecondCount()
 	return getTickCount() * 0.001
end

function DamageHud:paint(g)


	if(isElement(self.attacker) and getTickCount() < self.endTicks) then

		-- Ensure at least 1 second since g_BeginValidSeconds was set
		local timeSeconds = self:getSecondCount()

		-- Icon definition
		local icon = { file="gfx/hud/damage_ind.png", w=80, h=56 }

		-- Calc smoothing vars
		local delta = timeSeconds
		local timeslice = math.clamp(0,delta*14,1)



		-- Get screen dimensions
		local screenX,screenY = guiGetScreenSize()
		local halfScreenX = screenX * 0.5
		local halfScreenY = screenY * 0.5

		-- Get my pos and rot
		local mx, my, mz = getElementPosition(localPlayer)
		local _, _, mrz	= self:getCameraRot()

		-- To radians
		mrz = math.rad(-mrz)

		local ox, oy, oz = getElementPosition(self.attacker)

		local maxDistance = 60
		local alpha = 1 - getDistanceBetweenPoints3D( mx, my, mz, ox, oy, oz ) / maxDistance
		local onScreen = getScreenFromWorldPosition ( ox, oy, oz )


		-- Calc draw scale
		local scalex = alpha * 0.5 + 0.5
		local scaley = alpha * 0.25 + 0.75

		-- Calc dir to
		local dx = ox - mx
		local dy = oy - my
		-- Calc rotz to
		local drz = math.atan2(dx,dy)
		-- Calc relative rotz to
		local rrz = drz - mrz
		local red,green,blue = 200,0,0

		-- Add smoothing to the relative rotz
		local smooth = rrz
		smooth = math.wrapdifference(-math.pi, smooth, rrz, math.pi)
		if math.abs(smooth-rrz) > 1.57 then
			smooth = rrz	-- Instant jump if more than 1/4 of a circle to go
		end
		smooth = math.lerp( smooth, rrz, timeslice )
		rrz = smooth

		local angle = 180 + rrz * 180 / math.pi
		local distance = 128.0
		local tx,ty,tw,th = self:getWidth()/2 - self.dw/2,self:getHeight()/2 - self.dh/2, self.dw, self.dh
		self.dx, self.dy = tx + distance * math.sin(math.rad(-angle)), ty + distance * math.cos(math.rad(-angle))

		--self.damageInd:setLocation(X-icon.w/2*scalex, Y-icon.h/2*scaley)
		self.damageInd:setBounds(self.dx, self.dy, self.dw, self.dh)
		self.damageInd:setAngle(-90 + rrz * 180 / math.pi)

		super.paint(self,g)
	else
		self:setVisible(false)
	end
end

function DamageHud:setVisible(visible)
	if(visible) then
		Toolkit.getInstance():add(self)
	else
		Toolkit.getInstance():remove(self)
	end
	super.setVisible(self, visible)
end

function DamageHud:addAttacker(attacker)
	self.attacker = attacker
	self.startTicks = getTickCount()
	self.endTicks = self.startTicks + 2000
end

function onLocalPlayerDamage(attacker, weapon, bodypart)
	local visible = isElement(getElementData(localPlayer, "event"))
	if(visible) then
		DamageHud.getInstance():addAttacker(attacker)
		DamageHud.getInstance():setVisible(visible)
	end
end
addEventHandler("onClientPlayerDamage", localPlayer, onLocalPlayerDamage, true, "high")
