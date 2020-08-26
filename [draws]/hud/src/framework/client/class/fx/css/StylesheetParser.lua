local super = Class("StylesheetParser", DocParser).getSuperclass()

function StylesheetParser:init()
	super.init(self)
	return self
end

function StylesheetParser:Style(s)
	return {type = "Style", value = s}
end

function StylesheetParser:Selector (s)
	return {type = "Selector", value = s}
end

function StylesheetParser:style (f, buf)
	local c = f:read(1)
	if c == "}" then
		coroutine.yield(self:Style(buf:append(c):content()))
		buf:clear()
		return self:selector(f, buf)
	elseif c then
		buf:append(c)
		return self:style(f, buf)
	else
		if buf:content() ~= "" then coroutine.yield(self:Style(buf:content())) end
	end
end

function StylesheetParser:selector(f, buf)
	local c = f:read(1)
	if c == "{" then
		if buf:content() ~= "" then coroutine.yield(self:Selector(buf:content())) end
		buf:set(c)
		return self:style(f, buf)
	elseif c then
		buf:append(c)
		return self:selector(f, buf)
	else
		if buf:content() ~= "" then coroutine.yield(self:Selector(buf:content())) end
	end
end

function StylesheetParser:getStylesFromSource(src)
	local cssSrc = string.trim(src)
	cssSrc = cssSrc:sub(2,cssSrc:len()-1)
	local styles = {}
	for k,v in pairs(string.explode(";", cssSrc)) do
		if(string.trim(v) ~= "") then
			local pair = string.explode(":", string.trim(v))
			local stylePair = {}
			stylePair[pair[1]] = pair[2]
			styles[k] = stylePair
		end
	end
	return styles
end

function StylesheetParser:parse(f)
	local stylesheet = Stylesheet.new():init()
	local style = {}
	local selectors = nil
	for i in self:makeiter(function () return self:selector(f, self:newbuf()) end) do
		if i.type == "Style" then
			local styles = self:getStylesFromSource(i.value)
			for i,selector in pairs(string.explode(",", selectors)) do
				selector = string.trim(selector)
				if(selector ~= "") then
					local pathNodes = string.explode(" ", selector)
					local pathCur = style
					for i,pathNode in pairs(pathNodes) do
						if(not pathCur[pathNode]) then
							pathCur[pathNode] = {}
						end
						pathCur = pathCur[pathNode]
					end
					pathCur._style = pathCur._style or styles or {}
					for k,v in pairs(styles) do
						if(type(v) == "table") then
							for id,val in pairs(v) do
								pathCur._style[id] = string.trim(val)	
							end
						end
					end
				end
			end	
		elseif i.type == "Selector" then
			selectors = string.trim(i.value)
		end
	end
	stylesheet.style = style
	return stylesheet
end

