--[[----------------------------------------------------
-- client script linker
-- @author ZoLo
-- @update 22/03/2010
----------------------------------------------------]]--

function playSfxSound(...)
	local soundResource = getResourceFromName("sound")
	if(soundResource) then
		call(soundResource, "playSfxSound", ...)
	end			
end

function callServerFunction(funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do
            if (type(value) == "number") then arg[key] = tostring(value) end
        end
    end
    -- If the serverside event handler is not in the same resource, replace 'resourceRoot' with the appropriate element
    triggerServerEvent("onClientCallsServerFunction", resourceRoot , funcname, unpack(arg))
end