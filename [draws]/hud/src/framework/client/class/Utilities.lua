local super = Class("Utilities", LuaObject).getSuperclass()

function Utilities.isLeftMouseButton(e)
	return getKeyState("mouse1")
end

function Utilities.isRightMouseButton(e)
	return getKeyState("mouse2")
end

function Utilities.isMiddleMouseButton(e)
	return getKeyState("mouse3")		
end

function Utilities.isRectangleContainingRectangle(a, b)
	return b.x >= a.x and (b.x + b.width) <= (a.x + a.width) and
		   b.y >= a.y and (b.y + b.height) <= (a.y + a.height)
end

function Utilities.getLocalBounds(c)
	b = Rectangle(c:getBounds())
	b.x = 0
	b.y = 0
	return b
end

function Utilities.getWindowAncestor(c)
	local p = c:getParent()	
	while(p ~= nil) do
		if (instanceOf(p, Window)) then
			return p
		end
		p = c:getParent()	
	end
	return nil
end

function Utilities.convertScreenLocationToParent(parent, x, y)
	local p = parent
	while(p ~= nil) do
		if (instanceOf(p, Window)) then
			local point = Point(x, y)
			SwingUtilities.convertPointFromScreen(point, parent)
			return point
		end
		p = c:getParent()	
	end
	outputDebugString("convertScreenLocationToParent: no window ancestor")
end

function Utilities.convertPoint(source, aPoint, destination)
	local p
	
	if(source == nil and destination == nil) then
		return aPoint
	end
	if(source == nil) then
		source = Utilities.getWindowAncestor(destination)
		if(source == nil) then
			outputDebugString("Source component not connected to component tree hierarchy")
		end
	end
	p = Point(aPoint)
	Utilities.convertPointToScreen(p, source)
	if(destination == nil) then
		destination = Utilities.getWindowAncestor(source)
		if(destination == nil) then
			outputDebugString("Destination component not connected to component tree hierarchy");
		end
	end
	Utilities.convertPointFromScreen(p,destination);
	return p;
end


function Utilities.getRootPane(c)
	if (instanceOf(c, RootPaneContainer)) then
		return c:getRootPane()
	end
	while(c ~= nil) do
		if (instanceOf(c, RootPane)) then
			return c
		end
		c = c:getParent()
	end
	return nil
end

function Utilities.getRoot(c)
	local p = c
	while(p ~= nil) do
		if (instanceOf(p, Window)) then
			return p
		end
		p = p:getParent()
	end
	return nil
end

function Utilities.getPaintingOrigin(c)
	local p = c
	p = p:getParent()
	while (instanceOf(p, Component)) do
		if (p:isPaintingOrigin()) then
			return p
		end
		p = p:getParent()
	end
	return nil
end

function Utilities.getDeepestComponentAt(parent, x, y)
	if (not parent:contains(x, y)) then
		return nil
	end
	if (instanceOf(parent, Container)) then
		local components = parent:getComponents()
		for i,comp in pairs(components.table) do
			if (comp ~= nil and comp:isVisible()) then
				local loc = {}
				loc.x, loc.y = comp:getLocation()
				if (instanceOf(comp, Container)) then
					comp = Utilities.getDeepestComponentAt(comp, x - loc.x, y - loc.y);
				else
					comp = comp:getComponentAt(x - loc.x, y - loc.y);
				end
				if (comp ~= nil and comp:isVisible()) then
					return comp
				end
			end
		end
	end
	return parent
end

function Utilities.windowForComponent(c)
	return Utilities.getWindowAncestor(c)
end

function Utilities.isDescendingFrom(a, b)
	if(a == b) then
		return true
	end
	local p = a:getParent()
	while(p ~= nil) do
		if(p == b) then
			return true
		end
		p = p:getParent()
	end
	return false
end

function Utilities.calculateInnerArea(c, r)
	if (c == nil) then
		return nil
	end
	local rect = r
	local insets = c:getInsets()

	if (rect == nil) then
		rect = Rectangle()
	end

	rect.x = insets.left
	rect.y = insets.top
	rect.width = c:getWidth() - insets.left - insets.right
	rect.height = c:getHeight() - insets.top - insets.bottom
	return rect
end

function Utilities.getValidateRoot(c, visibleOnly)
	local root = nil

	while(c ~= nil) do
		if (not c:isDisplayable() or instanceOf(c, CellRendererPane)) then
			return nil
		end
		if (c:isValidateRoot()) then
			root = c
			break
		end
		c = c:getParent()
	end

	if (root == nil) then
		return nil
	end

	while(c ~= nil) do
		if (not c:isDisplayable() or (visibleOnly and not c:isVisible())) then
			return nil
		end
		if (instanceOf(c, Window)) then
			return root;
		end
		c = c:getParent()
	end
	
	return nil
end


function Utilities.findDisplayedMnemonicIndex(text, mnemonic) 
	if (text == nil or mnemonic == '\0') then
		return -1
	end

	local uc = string.upper(string.char(mnemonic))
	local lc = string.lower(string.char(mnemonic))

	local uci = string.find(uc)
	local lci = string.find(lc)

	if (uci == nil) then
		return lci
	elseif(lci == nil) then
		return uci
	else
		return (lci < uci) and lci or uci
	end
end

function Utilities.tabbedPaneChangeFocusTo(comp)
	if (comp ~= nil) then
		if (comp:isFocusable()) then
			Utilities.compositeRequestFocus(comp);
			return true;
		elseif(instanceOf(comp, Component) and comp:requestDefaultFocus()) then
			return true;
		end
	end
	return false;
end




