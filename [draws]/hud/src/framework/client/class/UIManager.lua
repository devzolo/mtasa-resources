local super = Class("UIManager", LuaObject).getSuperclass()

function UIManager.getBoolean(key)
	return UIManager.getDefaults().getBoolean(key)
end

function UIManager.getDefaults()
	UIManager.maybeInitialize()
	return UIManager.defaults
end

function UIManager.maybeInitialize()
	if (not UIManager.initialized) then
		UIManager.initialized = true
		UIManager.initialize()
	end
end

function UIManager.getColor(key)
	return SystemColor[key] or Color[key] or UIManager.getDefaults().getColor(key)
end
	
function UIManager.initialize()
	local defaults = {}
	defaults.colors = {}
	defaults.getColor = function(key)
		return defaults.colors[key]
	end
	UIManager.defaults = defaults
end

