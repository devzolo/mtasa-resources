local super = Class("ButtonGroup", LuaObject).getSuperclass()

function ButtonGroup:init()
	super.init(self)
	self.buttons = ArrayList()
	return self
end

function ButtonGroup:add(b)
    if(b == nil) then
        return
    end
    self.buttons:add(b)
	if (b:isSelected()) then
		if (self.selection == nil) then
			self.selection = b:getModel()
		else
			b:setSelected(false)
		end
	end
end









