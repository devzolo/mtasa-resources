local super = Class("DefaultFocusTraversalPolicy", ContainerOrderFocusTraversalPolicy).getSuperclass()

function DefaultFocusTraversalPolicy:init()
	super.init(self)
	return self
end

function DefaultFocusTraversalPolicy:accept(aComponent)
	if (not(aComponent:isVisible() and aComponent:isDisplayable() and aComponent:isEnabled())) then
		return false
	end
	-- Verify that the Component is recursively enabled.
	if (not(instanceOf(aComponent, Window))) then
		local enableTest = aComponent:getParent()
		while(enableTest) do
			if (not(enableTest:isEnabled())) then
				return false
			end
			if (instanceOf(enableTest, Window)) then
				break
			end
			enableTest = aComponent:getParent()
		end
	end
	return aComponent:isFocusable()
end