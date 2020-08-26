function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function math.lerp(from,to,alpha)
	return from + (to-from) * alpha
end

function math.clamp(low,value,high)
	return math.max(low,math.min(value,high))
end

function math.wrap(low,value,high)
	while value > high do
		value = value - (high-low)
	end
	while value < low do
		value = value + (high-low)
	end
	return value
end

function math.wrapdifference(low,value,other,high)
	return math.wrap(low,value-other,high)+other
end

