local super = Class("Animation", LuaObject).getSuperclass()

Animation.INDEFINITE = -1;

Animation.Status = {
	PAUSED = 1,
	RUNNING = 2,
	STOPPED = 3,
}

Animation.EPSILON = 1e-12;

Animation.instances = ArrayList("table")

function Animation.process(timeSlice)

end

function Animation.instanceAdd(animation)
	if(Animation.instances:isEmpty()) then
		if(not isEventHandlerAdded("onClientPreRender", root, Animation.process)) then
			addEventHandler("onClientPreRender", root, Animation.process, true, "low")
		end
	end
	Animation.instances:add(animation)
end

function Graphics.instanceRemove(animation)
	Animation.instances:remove(animation)
	if(Animation.instances:isEmpty()) then
		if(isEventHandlerAdded("onClientPreRender", root, Animation.process)) then
			removeEventHandler("onClientPreRender", root, Animation.process)
		end
	end
end

function Animation:init()
	super.init(self)
    self.startTime
    self.pauseTime
    self.paused = false
    self.timer
	return self
end


function Animation:play()
	if (self.parent ~= nil) then
		error("Cannot start when embedded in another animation")
	end
	
	local status = self:getStatus()
	
	if(status == Animation.Status.STOPPED) then
        if (self:startable(true)) then
			local rate = self:getRate()
			if (self.lastPlayedFinished) then
				self:jumpTo((rate < 0) and self:getTotalDuration() or Duration.ZERO);
			end
			self:start(true)
			self:startReceiver(TickCalculation.fromDuration(getDelay()));
			if (math.abs(rate) < Animation.EPSILON) then
				self:pauseReceiver()
			else 

			end
		else
			local handler = self:getOnFinished()
			if (handler ~= nil) then
				handler:handle(ActionEvent(self, nil))
			end
		end
	elseif(status == Animation.Status.PAUSED) then
		self:resume()
		if (math.abs(self:getRate()) >= Animation.EPSILON) then
			self:resumeReceiver();
		end
	end
end

function Animation:stop()
	if (self.parent ~= nil) then
		error("Cannot stop when embedded in another animation")
	end

	if(self:getStatus() ~= Animation.Status.STOPPED) then
		self.clipEnvelope:abortCurrentPulse();
		impl_stop();
		jumpTo(Duration.ZERO);
	end
end

function Animation:playFromStart()
	self:stop()
	self:setRate(math.abs(self:getRate()))
	self:jumpTo(Duration.ZERO)
	self:play()
end




