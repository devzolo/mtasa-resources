local super = Class("CheckboxGroup", Component).getSuperclass()

function CheckboxGroup:init()
	super.init(self)
	return self
end

function CheckboxGroup:getSelectedCheckbox()
	return self.selectedCheckbox;
end


function CheckboxGroup:setSelectedCheckbox(box)
	if (box ~= nil and box.group ~= self) then
		return
	end
	local oldChoice = self.selectedCheckbox
	self.selectedCheckbox = box
	if (oldChoice ~= nil and oldChoice ~= box and oldChoice.group == self) then
		oldChoice:setState(false)
	end
	if (box ~= nil and oldChoice ~= box and not box:getState()) then
		box:setStateInternal(true)
	end
end

function CheckboxGroup:toString()
	--return getClass().getName() + "[selectedCheckbox=" + selectedCheckbox + "]";
	return "CheckboxGroup"
end