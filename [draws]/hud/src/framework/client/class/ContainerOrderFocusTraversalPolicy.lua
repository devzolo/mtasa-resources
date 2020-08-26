local super = Class("ContainerOrderFocusTraversalPolicy", LuaObject).getSuperclass()

ContainerOrderFocusTraversalPolicy.FORWARD_TRAVERSAL = 0
ContainerOrderFocusTraversalPolicy.BACKWARD_TRAVERSAL = 1

function ContainerOrderFocusTraversalPolicy:init()
	super.init(self)
    self.implicitDownCycleTraversal = true
    self.cachedRoot = nil
    self.cachedCycle = nil	
	return self
end

function ContainerOrderFocusTraversalPolicy:getFocusTraversalCycle(aContainer)
	local cycle = ArrayList()
	self:enumerateCycle(aContainer, cycle)
	return cycle
end

function ContainerOrderFocusTraversalPolicy:getComponentIndex(cycle, aComponent)
	return cycle:indexOf(aComponent)
end

function ContainerOrderFocusTraversalPolicy:enumerateCycle(container, cycle)

	if (not(container:isVisible() and container:isDisplayable())) then
		return
	end

	--cycle:add(container)

	local components = container:getComponents()

	for i, comp in pairs(components.table) do
		local cancel = false
		--[[
		if (instanceOf(comp,Container)) then
			local cont = comp
			if (not cont:isFocusCycleRoot() and not cont:isFocusTraversalPolicyProvider()) then
				self:enumerateCycle(cont, cycle)
				cancel = true
			end
		end
		]]
		if(not cancel) then
			cycle:add(comp)
		end
	end
end

function ContainerOrderFocusTraversalPolicy:getTopmostProvider(focusCycleRoot, aComponent)
	local aCont = aComponent:getParent()
	local ftp = nil
	
	while(aCont ~= focusCycleRoot and aCont ~= nil) do
		if (aCont:isFocusTraversalPolicyProvider()) then
			ftp = aCont
		end
		aCont = aCont:getParent()
	end
	if (aCont == nil) then
		return nil
	end
	return ftp
end

function ContainerOrderFocusTraversalPolicy:getComponentDownCycle(comp, traversalDirection) 
	local retComp = nil
	if (instanceOf(comp, Container)) then
		local cont = comp
		if (cont:isFocusCycleRoot()) then
			if (self:getImplicitDownCycleTraversal()) then
				retComp = cont:getFocusTraversalPolicy():getDefaultComponent(cont)
			else
				return nil
			end
		elseif(cont:isFocusTraversalPolicyProvider()) then
			if(traversalDirection == ContainerOrderFocusTraversalPolicy.FORWARD_TRAVERSAL) then
				retComp = cont:getFocusTraversalPolicy():getDefaultComponent(cont)
			else
				retComp = cont:getFocusTraversalPolicy():getLastComponent(cont)
			end
		end
	end
	return retComp
end

function ContainerOrderFocusTraversalPolicy:getComponentAfter(aContainer, aComponent)

	if (aContainer == nil or aComponent == nil) then
		outputDebugString("aContainer and aComponent cannot be nil")
		return nil
	end
	
	if (not aContainer:isFocusTraversalPolicyProvider() and not aContainer:isFocusCycleRoot()) then
		outputDebugString("aContainer should be focus cycle root or focus traversal policy provider")
		return nil
	elseif (aContainer:isFocusCycleRoot() and not aComponent:isFocusCycleRoot(aContainer)) then
		outputDebugString("aContainer is not a focus cycle root of aComponent")
		return nil
	end
	
	if (not (aContainer:isVisible() and aContainer:isDisplayable())) then
		return nil
	end

	-- Before all the ckecks below we first see if it's an FTP provider or a focus cycle root.
	-- If it's the case just go down cycle (if it's set to "implicit").
	local comp = self:getComponentDownCycle(aComponent, ContainerOrderFocusTraversalPolicy.FORWARD_TRAVERSAL)
	if (comp ~= nil) then
		return comp
	end

	-- See if the component is inside of policy provider.
	local provider = self:getTopmostProvider(aContainer, aComponent)
	if (provider ~= nil) then
		-- FTP knows how to find component after the given. We don't.
		local policy = provider:getFocusTraversalPolicy()
		local afterComp = policy:getComponentAfter(provider, aComponent)

		-- nil result means that we overstepped the limit of the FTP's cycle.
		-- In that case we must quit the cycle, otherwise return the component found.
		if (afterComp ~= nil) then
			return afterComp
		end
		aComponent = provider
	end

	local cycle = self:getFocusTraversalCycle(aContainer)

	local index = self:getComponentIndex(cycle, aComponent)

	if (index < 1) then
		return self:getFirstComponent(aContainer)
	end

	index = index + 1
	while(index <= cycle:size()) do
		comp = cycle:get(index)
		if (self:accept(comp)) then
			return comp
		else
			comp = self:getComponentDownCycle(comp, ContainerOrderFocusTraversalPolicy.FORWARD_TRAVERSAL)
			if (comp ~= nil) then
				return comp
			end
		end
		index = index + 1
	end

	if (aContainer:isFocusCycleRoot()) then
		self.cachedRoot = aContainer
		self.cachedCycle = cycle

		comp = self:getFirstComponent(aContainer)

		self.cachedRoot = nil
		self.cachedCycle = nil

		return comp
	end

	return nil
end
	
function ContainerOrderFocusTraversalPolicy:getComponentBefore(aContainer, aComponent)
	if (aContainer == nil or aComponent == nil) then
		outputDebugString("aContainer and aComponent cannot be nil")
		return nil
	end
	if (not aContainer:isFocusTraversalPolicyProvider() and not aContainer:isFocusCycleRoot()) then
		outputDebugString("aContainer should be focus cycle root or focus traversal policy provider")
		return nil
	elseif (aContainer:isFocusCycleRoot() and not aComponent:isFocusCycleRoot(aContainer)) then
		outputDebugString("aContainer is not a focus cycle root of aComponent")
		return nil
	end


	if (not (aContainer:isVisible() and aContainer:isDisplayable())) then
		return nil
	end

	-- See if the component is inside of policy provider.
	local provider = self:getTopmostProvider(aContainer, aComponent)
	if (provider ~= nil) then

		-- FTP knows how to find component after the given. We don't.
		local policy = provider:getFocusTraversalPolicy()
		local beforeComp = policy:getComponentBefore(provider, aComponent)

		-- nil result means that we overstepped the limit of the FTP's cycle.
		-- In that case we must quit the cycle, otherwise return the component found.
		if (beforeComp ~= nil) then
			return beforeComp
		end
		
		aComponent = provider

		-- If the provider is traversable it's returned.
		if (self:accept(aComponent)) then
			return aComponent
		end
	end

	local cycle = self:getFocusTraversalCycle(aContainer)

	local index = self:getComponentIndex(cycle, aComponent)

	if (index < 1) then
		return self:getLastComponent(aContainer)
	end

	local comp = nil
	local tryComp = nil

	
	index = index - 1
	while(index >= 1) do	
		comp = cycle:get(index)
		if (comp ~= aContainer) then
			tryComp = self:getComponentDownCycle(comp, ContainerOrderFocusTraversalPolicy.BACKWARD_TRAVERSAL)
			if(tryComp ~= nil) then
				return tryComp
			end
		elseif (self:accept(comp)) then
			return comp
		end
		index = index - 1
	end

	if (aContainer:isFocusCycleRoot()) then
		self.cachedRoot = aContainer
		self.cachedCycle = cycle

		comp = self:getLastComponent(aContainer)

		self.cachedRoot = nil
		self.cachedCycle = nil
		return comp
	end

	return nil
end

function ContainerOrderFocusTraversalPolicy:getFirstComponent(aContainer)


	local cycle = nil

	if (not aContainer) then
		outputDebugString("aContainer cannot be nil")
	end

	if (not(aContainer:isVisible() and aContainer:isDisplayable())) then
		return nil
	end

	if (self.cachedRoot == aContainer) then
		cycle = self.cachedCycle
	else
		cycle = self:getFocusTraversalCycle(aContainer)
	end

	if (cycle:size() == 0) then
		return nil
	end


	for i, comp in pairs(cycle.table) do
		if (self:accept(comp)) then
			return comp
		elseif(comp ~= aContainer) then
			comp = self:getComponentDownCycle(comp, ContainerOrderFocusTraversalPolicy.FORWARD_TRAVERSAL)
			if(comp) then
				return comp
			end
		end	
	end	

	return nil
end

function ContainerOrderFocusTraversalPolicy:getLastComponent(aContainer) 
	local cycle = nil
	
	if (not aContainer) then
		outputDebugString("aContainer cannot be nil")
	end

	if (not(aContainer:isVisible() and aContainer:isDisplayable())) then
		return nil
	end

	if (self.cachedRoot == aContainer) then
		cycle = self.cachedCycle
	else
		cycle = self:getFocusTraversalCycle(aContainer)
	end

	if (cycle:size() == 0) then
		return nil
	end
	
	local i = cycle:size()
	
	while(i >= 1) do
		local comp = cycle:get(i)
		if (self:accept(comp)) then
			return comp
		elseif(instanceOf(comp, Container) and comp ~= aContainer) then
			local cont = comp
			if (cont:isFocusTraversalPolicyProvider()) then
				return cont:getFocusTraversalPolicy():getLastComponent(cont)
			end
		end		
		
		i = i - 1
	end
	return nil
end
	
	
function ContainerOrderFocusTraversalPolicy:getDefaultComponent(aContainer)
	return self:getFirstComponent(aContainer)
end

function ContainerOrderFocusTraversalPolicy:setImplicitDownCycleTraversal(implicitDownCycleTraversal)
	self.implicitDownCycleTraversal = implicitDownCycleTraversal
end
	
function ContainerOrderFocusTraversalPolicy:getImplicitDownCycleTraversal()
	return self.implicitDownCycleTraversal
end

function ContainerOrderFocusTraversalPolicy:accept(aComponent)
	
	if (not aComponent:canBeFocusOwner()) then
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
			enableTest = enableTest:getParent()
		end
	end
	return true
end

  
