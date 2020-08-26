local super = Class("Toolkit", LuaObject).getSuperclass()

function Toolkit.getInstance()
	return LuaObject.getSingleton("Toolkit")
end

function Toolkit.toEventParams(state, button)

	local mbutton
	local mstate
	
	if(state == 'down') then
		mstate = MouseEvent.MOUSE_PRESSED
	elseif(state == 'up') then
		mstate = MouseEvent.MOUSE_RELEASED
	elseif(state == 'double') then
		mstate = MouseEvent.MOUSE_CLICKED
	end

	if(button == 'left') then
		mbutton = MouseEvent.BUTTON1
	elseif(button == 'right') then
		mbutton = MouseEvent.BUTTON2
	elseif(button == 'middle') then
		mbutton = MouseEvent.BUTTON3
	end

	return mstate, mbutton
end

function Toolkit.toCharacter(button)
	if(button == 'enter') then
		return KeyEvent.VK_ENTER
	elseif(button == 'backspace') then
		return KeyEvent.VK_BACK_SPACE
	elseif(button == 'tab') then
		return KeyEvent.VK_TAB
	end
	return false
end

function Toolkit:init()
	super.init(self)
	self.container = Graphics.getInstance()
	MouseInfo.setPointLocation(self.container:getWidth()/2, self.container:getHeight()/2)

	self.onCursorMove = function (cursorX, cursorY, absoluteX, absoluteY, worldX, worldY, worldZ)
		if isMTAWindowActive() then
			return
		end
		local x = absoluteX
		local y = absoluteY

		if(x < 0) then
			x = 0
		elseif(x > self.container:getWidth()) then
			x = self.container:getWidth()
		end

		if(y < 0) then
			y = 0
		elseif(y > self.container:getHeight()) then
			y = self.container:getHeight()
		end

		MouseInfo.setPointLocation(x, y)

		local e = MouseEvent(self.container, MouseEvent.MOUSE_MOVED, 0, 0, x, y, x, y, 0, false, 0)
		--self.container:processEvent(e)

		local component = self.container:getComponentAt(x,y)
		if(component) then
			component:processEvent(e)	
			local drag = getKeyState("mouse1") or getKeyState("mouse2") or getKeyState("mouse3")
			if(drag) then
				--local e = MouseEvent(self.container, MouseEvent.MOUSE_DRAGGED, 0, 0, x, y, x, y, 0, false, 0)
				e.id = MouseEvent.MOUSE_DRAGGED
				component:processEvent(e)
			end
		end
		
		if(component ~= MouseInfo.getOverComponent()) then
			local overComponent = MouseInfo.getOverComponent()
			if(overComponent and overComponent.parent) then
				e = MouseEvent(overComponent, MouseEvent.MOUSE_EXITED, 0, 0, x, y, x, y, 0, false, 0)
				overComponent:processEvent(e)	
			end
			e = MouseEvent(component, MouseEvent.MOUSE_ENTERED, 0, 0, x, y, x, y, 0, false, 0)
			if(component) then
				component:processEvent(e)
			end
			MouseInfo.setOverComponent(component)
		end
	end
	
	self.onClientDoubleClick = function (button, absoluteX, absoluteY, worldX, worldY, worldZ, clickedWorld)
		self.onClick(button, "double", absoluteX, absoluteY, worldX, worldY, worldZ, clickedWorld)
	end
	
	self.onClick = function (button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedWorld)
		if isMTAWindowActive() then
			return
		end	
		local x = absoluteX
		local y = absoluteY
		local component = self.container:getComponentAt(x,y)
		--local component = Utilities.getDeepestComponentAt(self.container, x, y)
		
		local owner = KeyboardFocusManager.getCurrentKeyboardFocusManager():getFocusOwner()
		if (owner and component ~= owner) then
			-- Scrollbar stuf
			if(instanceOf(owner, Scrollbar)) then
				owner.drag = false
			elseif(instanceOf(owner, TextField)) then
				KeyboardFocusManager.getCurrentKeyboardFocusManager():setGlobalFocusOwner(nil)
				guiMoveToBack(owner.guiEdit)
				guiSetInputEnabled(false)	
			end
		end		
		
		
		if(component ~= nil) then
			local state, button = Toolkit.toEventParams(state, button)
			local e = MouseEvent(component,state,0,0,x,y,x,y,0,false,button)
			component:processEvent(e)
			--if (KeyboardFocusManager.getCurrentKeyboardFocusManager().getGlobalFocusOwner() ~= component) then
			--	KeyboardFocusManager.getCurrentKeyboardFocusManager():setGlobalFocusOwner(nil)
			--end	
		end
		

	end
	
	self.onClientKey = function (button, press)
		if (press) then -- Only output when they press it down
			if(button == "mouse_wheel_down") then
				local absoluteX, absoluteY = MouseInfo.getPoint()
				local x = absoluteX
				local y = absoluteY
				local component = self.container:getComponentAt(x,y)
				if(component ~= nil) then
					local e = MouseEvent(component,MouseEvent.MOUSE_WHEEL,0,0,x,y,x,y,0,false,button)
					component:processEvent(e)
				end
			elseif(button == "mouse_wheel_up") then
				local absoluteX, absoluteY = MouseInfo.getPoint()
				local x = absoluteX
				local y = absoluteY
				local component = self.container:getComponentAt(x,y)
				if(component ~= nil) then
					local e = MouseEvent(component,MouseEvent.MOUSE_WHEEL,0,0,x,y,x,y,0,false,button)
					component:processEvent(e)
				end			
			end

			local character = Toolkit.toCharacter(button)
			if(character) then
				local component = KeyboardFocusManager.getCurrentKeyboardFocusManager():getFocusOwner()
				if (component and instanceOf(component, TextField)) then
					local e = KeyEvent(component,KeyEvent.KEY_TYPED,0,0,0,character,0)
					component:processEvent(e)
				end	
			end
		end
	end
	
	self.onClientCharacter = function (character)
		local component = KeyboardFocusManager.getCurrentKeyboardFocusManager():getFocusOwner()
		if (component and instanceOf(component, TextField)) then
			local e = KeyEvent(component,KeyEvent.KEY_TYPED,0,0,0,character,0)
			component:processEvent(e)
		end
	end	
	addEventHandler("onClientCharacter", root, self.onClientCharacter)
	addEventHandler("onClientCursorMove", root, self.onCursorMove)
	addEventHandler("onClientClick", root, self.onClick)
	addEventHandler("onClientDoubleClick", root, self.onClientDoubleClick)
	addEventHandler("onClientKey", root, self.onClientKey)

	--Toolkit.onCursorMove
	return self
end

function Toolkit:add(component)
	return self.container:add(component)
end

function Toolkit:remove(component)
	return self.container:remove(component)
end

function Toolkit.getNativeContainer()
	return Toolkit.getInstance().container
end

