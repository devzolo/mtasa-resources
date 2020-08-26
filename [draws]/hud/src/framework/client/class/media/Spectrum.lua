local super = Class("Spectrum", Panel).getSuperclass()

function Spectrum:init()
	super.init(self)
	return self
end

function Spectrum:setSound(sound)
	self.sound = sound
end

function Spectrum:paintComponent(g)
	super.paintComponent(self,g)
	
	local x, y = self:getLocationOnScreen()
	local w = self.width
	local h = self.height	
	
	if(isElement(self.sound)) then
		local fftData = getSoundFFTData(self.sound, 8192, 32)
		if(fftData and #fftData > 0) then
			local txWidth = (w - #fftData) / #fftData 
			if(self.nodeData == nil) then
				self.nodeData = {}
			end
			for i,v in pairs(fftData) do
				local theHeight = math.round((v*self.height*2),0)
				if(theHeight > self.height) then
					theHeight = self.height
				end

				local dx,dy,dw,dh = x+(i*txWidth), y+self.height, txWidth-1, theHeight*-1
				
				if(not self.nodeData[i]) then
					self.nodeData[i] = {x=dx,y=dy}
				end
				if(not isSoundPaused(self.sound)) then
					local node = self.nodeData[i]
					self.nodeData[i].y = self.nodeData[i].y + 0.5
					local nodeY = math.min(self.nodeData[i].y, dy + dh) or 0
					self.nodeData[i].color = self.nodeData[i].y > dy + dh and tocolor(math.random(255),math.random(255),math.random(255),255) or self.nodeData[i].color or tocolor(255,255,255,255)
					self.nodeData[i].x = dx
					self.nodeData[i].y = math.min(math.max(nodeY, y), dy - 3) or 0
				end
				g:drawSetColor(self.nodeData[i].color)
				
				g:drawFilledRect(self.nodeData[i].x, self.nodeData[i].y, txWidth, 3)	
				g:drawSetColor(tocolor(255,255,255,255))
				
				g:drawFilledRect(dx,   dy,   dw, 1)
				g:drawFilledRect(dx+dw, dy,   1, dh)
				g:drawFilledRect(dx,   dy,   1, dh)
				g:drawFilledRect(dx,   dy+dh, dw, 1)
				g:drawSetColor(tocolor(100,100,100,255))
				g:drawSetColor(self.nodeData[i].color)
				g:drawFilledRect(dx + 1, dy + 1, dw - 1, dh - 1)	
			end
		end
	end
end

