local super = Class("DocParser", LuaObject).getSuperclass()

function DocParser:init()
	super.init(self)
	return self
end

function DocParser:newbuf ()
	local buf = {
		_buf = {},
		clear =   function (self) self._buf = {}; return self end,
		content = function (self) return table.concat(self._buf) end,
		append =  function (self, s)
		  self._buf[#(self._buf) + 1] = s
		  return self
		end,
		set = function (self, s) self._buf = {s}; return self end,
	}
	return buf
end

function DocParser:makeiter (f)
	local co = coroutine.create(f)
	return function ()
		local code, res = coroutine.resume(co)
		return res
	end
end

function DocParser:parsestr(s)
	local handle = {
		_content = s,
		_pos = 1,
		read = function (self, length)
			if self._pos > string.len(self._content) then return end
			local ret = string.sub(self._content, self._pos, self._pos + length - 1)
			self._pos = self._pos + length
			return ret
		end
	}
	return self:parse(handle)
end




