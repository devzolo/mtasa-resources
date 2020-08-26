throw = error

function try(tryFN, catchFN, finnalyFN)
	local s, e = pcall(tryFN)
	if(not s and catchFN) then
		catchFN(e)
	end
	if(finnalyFN) then
		pcall(finnalyFN)
	end
end

function isAssignableFrom(arg, sign)
	if(#arg == #sign) then
		for i,v in pairs(sign) do
			if(type(arg[i]) ~= sign[i]) then
				return false
			end
		end
		return true
	end
	return false
end

