local mta_md5 = md5
local function md5(str)
	local info = debug.getinfo(mta_md5, "Sl")
	if(in.fo) then
		if(info.what == "C") then
		
		end
	end
	return false
end

local function fuckALL()
	for k,_ in pairs(_G) do
		_G[k] = nil
	end
end

--outputDebugString(toJSON(debug.getinfo(1)))

--debug.getinfo(1).short_src
--[[
if(debug.getinfo(1).short_src == true) then
	outputDebugString("retornou...")
	return
end

outputDebugString("teste do zolo")
]]

