
addEventHandler("onClientResourceStart", resourceRoot, function(resource) 
	--local frame = Frame("Teste")
	--frame:setBounds(100,100,400,300)
	--frame:setVisible(true)
	
	--Toolkit.getInstance():add(frame)
	
	--[[
	local optionPane = OptionPane.showMessageDialog(nil, "teste...", "Teste", OptionPane.YES_OPTION, OptionPane.INFORMATION_MESSAGE, icon, options, initialValue)
	optionPane:setBounds(100,100,400,300)
	optionPane:setVisible(true)
	Toolkit.getInstance():add(optionPane)
	showCursor(true)
	]]
end)

function onClientWebResponse(url, data)
	HTML.updateResponseImage(url, data)
end
addEvent("onClientWebResponse",true)
addEventHandler( "onClientWebResponse", root, onClientWebResponse)


function string:split(separator)
	if separator == '.' then
		separator = '%.'
	end
	local result = {}
	for part in self:gmatch('(.-)' .. separator) do
		result[#result+1] = part
	end
	result[#result+1] = self:match('.*' .. separator .. '(.*)$') or self
	return result
end

addEvent('onClientCall_hud', true)
addEventHandler('onClientCall_hud', resourceRoot,
	function(fnName, ...)
		local fn = _G
		local path = fnName:split('.')
		for i,pathpart in ipairs(path) do
			fn = fn[pathpart]
		end
        if not fn then
            outputDebugString( 'onClientCall_hud fn is nil for ' .. tostring(fnName) )
        else
    		fn(...)
        end
	end
)

function serverCall(player, fnName, ...)
	triggerServerEvent('onServerCall_hud', resourceRoot, fnName, ...)
end


addEvent('onClientHudCall', true)
function onClientHudCall(code)
	local chunk = loadstring(code)
	if(chunk) then
		chunk()
	end
end
addEventHandler('onClientHudCall', root, onClientHudCall)




