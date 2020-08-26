local super = Class("AbstractButton", Component).getSuperclass()

function AbstractButton:init()
	super.init(self)
	return self
end

function AbstractButton:setEnabled(b)
	if (not b and self.model:isRollover()) then
		self.model:setRollover(false)
	end
	super.setEnabled(self,b)
	self.model:setEnabled(b)
end

  
