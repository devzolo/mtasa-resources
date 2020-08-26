function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
	if(type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function') then
		local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
		if(type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0) then
			for i, v in ipairs( aAttachedFunctions ) do
				if(v == func) then
					return true
				end
			end
		end
	end
	return false
end

function isKeyBound(key, keyState, handler)
  local handlers = getFunctionsBoundToKey(key)
  for k,v in pairs(handlers or {}) do
    if(v == handler) then
      return true
    end
  end
  return false
end

function toang(value)
	if(value > 360.0) then
		while(value > 360.0) do
			value = value - 360.0
		end
	elseif(value < 0.0) then
		while(value < 0.0) do
			value = value + 360.0
		end
	end
	return value;
end


function eval(script)
	local f = loadstring(script)
	if(f) then
		return f()
	end
end

function trim(s)
  -- from PiL2 20.4
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function px(s)
  local n = 1
  while true do
    while true do -- removes spaces
      local _, ne, np = s:find("^[^%s%%]*()%s*", n)
      n = np
      if np - 1 ~= ne then s = s:sub(1, np - 1) .. s:sub(ne + 1)
      else break end
    end
    local m = s:match("%%(.?)", n) -- skip magic chars
    if m == "b" then n = n + 4
    elseif m then n = n + 2
    else break end
  end
  return s
end

function getColorAlpha(color)
   return bitExtract(color,24,8) -- return bits 24-32
end

function replaceColorAlpha(color, alpha)
  return tocolor(bitExtract(color,16,8), bitExtract(color,8,8), bitExtract(color,0,8), alpha)
end

function hex2rgba(hex)
  hex = hex:gsub("#","")
  local a = tonumber("0x"..hex:sub(7,8)) or 255
  return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)), a
end

function hex2color(hex)
	return tocolor(hex2rgba(hex))
end

function iif(cond,v1,v2)
	if(cond) then
		return v1
	end
	return v2
end


function getFrameTime()
	return g_frameTime
end

function onClientPreRender (timeSlice)
	g_frameTime = timeSlice
end
addEventHandler("onClientPreRender", root, onClientPreRender)


function msToTimeStr(ms)
	if not ms then
		return ''
	end
	local centiseconds = tostring(math.floor(math.fmod(ms, 1000)/10))
	if #centiseconds == 1 then
		centiseconds = '0' .. centiseconds
	end
	local s = math.floor(ms / 1000)
	local seconds = tostring(math.fmod(s, 60))
	if #seconds == 1 then
		seconds = '0' .. seconds
	end
	local minutes = tostring(math.floor(s / 60))
	return minutes .. ':' .. seconds .. ':' .. centiseconds
end

function showDefaultHUD(show)
    for i,name in ipairs({ 'ammo', 'area_name', 'armour', 'breath', 'clock', 'health', 'money', 'vehicle_name', 'weapon' , 'radar', 'wanted'}) do
        showPlayerHudComponent(name, show)
    end
end

function findRotation(x1,y1,x2,y2)
  local t = -math.deg(math.atan2(x2-x1,y2-y1))
  if t < 0 then t = t + 360 end
  return t
end

function getDistanceRotation(x, y, dist, angle)
  local a = math.rad(90 - angle)
  local dx = math.cos(a) * dist
  local dy = math.sin(a) * dist
  return x+dx, y+dy
end

function getScalingFactorBasedOnSpeed()
	local veh = getPedOccupiedVehicle(getLocalPlayer())
	if veh then
		local vx, vy, vz = getElementVelocity(veh)
		local speed = math.abs(vx) + math.abs(vy) + math.abs(vz)

		local minSpeed = 0.3
		local maxSpeed = 1.5

		if speed >= minSpeed then
			return math.min(speed - minSpeed, maxSpeed)
		end
	end

	return 0
end

function getVehicleSpeed(veh)
    if isElement(veh) then
        local vx, vy, vz = getElementVelocity(veh)
        local velocidade = math.sqrt(vx^2 + vy^2 + vz^2) * 180 --kmh
		return math.floor(velocidade)
    end
    return 0
end

function getTimeString()
	local time = getRealTime()
	local horas = time.hour
	if (horas >= 0 and horas < 10) then
		horas = '0'..time.hour..''
	end
	local minutos = time.minute
	if (minutos >= 0 and minutos < 10) then
		minutos = '0'..time.minute..''
	end
	local segundos = time.second
	if (segundos >= 0 and segundos < 10) then
		segundos = '0'..time.second..''
	end
	return horas..':'..minutos..':'..segundos
end

function getDateString()
	local time = getRealTime()

	local dia = time.monthday
	if (dia > 0 and dia < 10) then
		dia = '0'..time.monthday..''
	end
	local mes = time.month+1
	if (mes >= 0 and mes < 10) then
		mes = '0'..mes..''
	end
	local ano = -100 + time.year

	return dia..'/'..mes..'/'..ano
end

function ajax(request, ...)
	if(request and request.url) then
		local postData = ""
		local getData = ""
		local postIsBinary = false
		if(string.lower(request.type) == "post") then
			if(type(request.data) == "table") then
				for k,v in pairs(request.data) do
					if(postData == "") then
						postData = postData .. k .. "=" .. v
					else
						postData = postData .. "&" .. k .. "=" .. v
					end
				end
			end	
		else
			if(type(request.data) == "table") then
				for k,v in pairs(request.data) do
					if(getData == "") then
						getData = "?" .. getData .. k .. "=" .. v
					else
						getData = getData .. "&" .. k .. "=" .. v
					end
				end
			end		
		end	
		if(request.processData == false) then
			postIsBinary = true
		end
		outputDebugString(request.url .. getData)
		fetchRemote(request.url .. getData, 100, request.response, postData, postIsBinary, ...)	
	end
end

