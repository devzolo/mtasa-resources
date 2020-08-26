local hud = ColorChooser()
hud:setBounds(200,200, 900/5, 600/5)
hud:setBackground(tocolor(50,50,50,255))
hud:setForeground(tocolor(255,255,255,255))	
hud:addChangeListener({
	stateChanged = function(e)
		hud:setBackground(e.source:getColor())
	end
})
showCursor(true)
Toolkit.getInstance():add(hud)