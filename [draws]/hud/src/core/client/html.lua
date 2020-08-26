local nl = "\n"

function htmlToText(buffer)
  local text = string.gsub (buffer,"(<([^>]-)>)",function (str) return str:lower() end)
  --[[ 
  First we kill the developer formatting (tabs, CR, LF)
  and produce a long string with no newlines and tabs.
  We also kill repeated spaces as browsers ignore them anyway.
  ]]
  local devkill=
    {
      ["("..string.char(10)..")"] = " ",
      ["("..string.char(13)..")"] = " ",
      ["("..string.char(15)..")"] = "",
      ["(%s%s+)"]=" ",
    }
  for pat, res in pairs (devkill) do
    text = string.gsub (text, pat, res)
  end
  -- Then we remove the header. We do this by stripping it first.
  text = string.gsub (text, "(<%s*head[^>]*>)", "<head>")
  text = string.gsub (text, "(<%s*%/%s*head%s*>)", "</head>")
  text = string.gsub (text, "(<head>,*<%/head>)", "")
  -- Kill all scripts. First we nuke their attribs.
  text = string.gsub (text, "(<%s*script[^>]*>)", "<script>")
  text = string.gsub (text, "(<%s*%/%s*script%s*>)", "</script>")
  text = string.gsub (text, "(<script>,*<%/script>)", "")
  -- Ok, same for styles.
  text = string.gsub (text, "(<%s*style[^>]*>)", "<style>")
  text = string.gsub (text, "(<%s*%/%s*style%s*>)", "</style>")
  text = string.gsub (text, "(<style>.*<%/style>)", "")
  
  -- Replace <td> and <th> with tabulators.
  text = string.gsub (text, "(<%s*td[^>]*>)","\t")
  text = string.gsub (text, "(<%s*th[^>]*>)","\t")
  
  -- Replace <br> with linebreaks.
  text = string.gsub (text, "(<%s*br%s*%/%s*>)",nl)
  
  -- Replace <li> with an asterisk surrounded by spaces.
  -- Replace </li> with a newline.
  text = string.gsub (text, "(<%s*li%s*%s*>)"," *  ")
  text = string.gsub (text, "(<%s*/%s*li%s*%s*>)",nl)
  
  -- <p>, <div>, <tr>, <ul> will be replaced to a double newline.
  text = string.gsub (text, "(<%s*div[^>]*>)", nl..nl)
  text = string.gsub (text, "(<%s*p[^>]*>)", nl..nl)
  text = string.gsub (text, "(<%s*tr[^>]*>)", nl..nl)
  text = string.gsub (text, "(<%s*%/*%s*ul[^>]*>)", nl..nl)
    
  -- Some petting with the <a> tags. :-P
  local addresses,c = {},0
  text=string.gsub(text,"<%s*a.-href=[\'\"](%S+)[\'\"][^>]*>(.-)<%s*%/*%s*a[^>]->", -- gets URL from a tag, and the enclosed name
  function (url,name)
    c = c + 1
    name = string.gsub (name, "<([^>]-)>","") -- strip name from tags (e. g. images as links)
    
    -- We only consider the URL valid if the name contains alphanumeric characters.
    if name:find("%w") then print(url, name, c) table.insert (addresses, {url, name}) return name.."["..#addresses.."]" else return "" end    
  end)

  -- Nuke all other tags now.
  text = string.gsub (text, "(%b<>)","")
  
  -- Replace entities to their correspondant stuff where applicable.
  -- C# is owned badly here by using a table. :-P
  -- A metatable secures entities, so you can add them natively as keys.
  -- Enclosing brackets also get added automatically (capture!)
  local entities = {}
  setmetatable (entities,
  {
    __newindex = function (tbl, key, value)
      key = string.gsub (key, "(%#)" , "%%#")
      key = string.gsub (key, "(%&)" , "%%&")
      key = string.gsub (key, "(%;)" , "%%;")
      key = string.gsub (key, "(.+)" , "("..key..")")
      rawset (tbl, key, value)
    end
  })
  entities = 
  {
    ["&nbsp;"] = " ",
    ["&bull;"] = " *  ",
    ["&lsaquo;"] = "<",
    ["&rsaquo;"] = ">",
    ["&trade;"] = "(tm)",
    ["&frasl;"] = "/",
    ["&lt;"] = "<",
    ["&gt;"] = ">",
    ["&copy;"] = "(c)",
    ["&reg;"] = "(r)",
    -- Then kill all others.
    -- You can customize this table if you would like to, 
    -- I just got bored of copypasting. :-)
    -- http://hotwired.lycos.com/webmonkey/reference/special_characters/
    ["%&.+%;"] = "",
  }
  for entity, repl in pairs (entities) do
    text = string.gsub (text, entity, repl)
  end
--   text = text..nl..nl..("-"):rep(27)..nl..nl
--   
--   for k,v in ipairs (addresses) do
--     text = text.."["..k.."] "..v[1]..nl
--   end
  if #addresses > 0 then
    text=text..nl:rep(2)..("-"):rep(2)..nl
    for key, tbl in ipairs(addresses) do
      text = text..nl.."["..key.."]"..tbl[1]
    end
  end
  
  return text
end



entity = {
  nbsp = " ",
  lt = "<",
  gt = ">",
  quot = "\"",
  amp = "&",
}

-- keep unknown entity as is
setmetatable(entity, {
  __index = function (t, key)
    return "&" .. key .. ";"
  end
})

block = {
  "address",
  "blockquote",
  "center",
  "dir", "div", "dl",
  "fieldset", "form",
  "h1", "h2", "h3", "h4", "h5", "h6", "hr", 
  "isindex",
  "menu",
  "noframes",
  "ol",
  "p",
  "pre",
  "table",
  "ul",
}

inline = {
  "a", "abbr", "acronym", "applet",
  "b", "basefont", "bdo", "big", "br", "button",
  "cite", "code",
  "dfn",
  "em",
  "font",
  "i", "iframe", "img", "input",
  "kbd",
  "label",
  "map",
  "object",
  "q",
  "s", "samp", "select", "small", "span", "strike", "strong", "sub", "sup",
  "textarea", "tt",
  "u",
  "var",
}

tags = {
  a = { empty = false },
  abbr = {empty = false} ,
  acronym = {empty = false} ,
  address = {empty = false} ,
  applet = {empty = false} ,
  area = {empty = true} ,
  b = {empty = false} ,
  base = {empty = true} ,
  basefont = {empty = true} ,
  bdo = {empty = false} ,
  big = {empty = false} ,
  blockquote = {empty = false} ,
  body = { empty = false, },
  br = {empty = true} ,
  button = {empty = false} ,
  caption = {empty = false} ,
  center = {empty = false} ,
  cite = {empty = false} ,
  code = {empty = false} ,
  col = {empty = true} ,
  colgroup = {
    empty = false,
    optional_end = true,
    child = {"col",},
  },
  dd = {empty = false} ,
  del = {empty = false} ,
  dfn = {empty = false} ,
  dir = {empty = false} ,
  div = {empty = false} ,
  dl = {empty = false} ,
  dt = {
    empty = false,
    optional_end = true,
    child = {
      inline,
      "del",
      "ins",
      "noscript",
      "script",
    },
  },
  em = {empty = false} ,
  fieldset = {empty = false} ,
  font = {empty = false} ,
  form = {empty = false} ,
  frame = {empty = true} ,
  frameset = {empty = false} ,
  h1 = {empty = false} ,
  h2 = {empty = false} ,
  h3 = {empty = false} ,
  h4 = {empty = false} ,
  h5 = {empty = false} ,
  h6 = {empty = false} ,
  head = {empty = false} ,
  hr = {empty = true} ,
  html = {empty = false} ,
  i = {empty = false} ,
  iframe = {empty = false} ,
  img = {empty = true} ,
  input = {empty = true} ,
  ins = {empty = false} ,
  isindex = {empty = true} ,
  kbd = {empty = false} ,
  label = {empty = false} ,
  legend = {empty = false} ,
  li = {
    empty = false,
    optional_end = true,
    child = {
      inline,
      block,
      "del",
      "ins",
      "noscript",
      "script",
    },
  },
  link = {empty = true} ,
  map = {empty = false} ,
  menu = {empty = false} ,
  meta = {empty = true} ,
  noframes = {empty = false} ,
  noscript = {empty = false} ,
  object = {empty = false} ,
  ol = {empty = false} ,
  optgroup = {empty = false} ,
  option = {
    empty = false,
    optional_end = true,
    child = {},
  },
  p = {
    empty = false,
    optional_end = true,
    child = {
      inline,
      "del",
      "ins",
      "noscript",
      "script",
    },
  } ,
  param = {empty = true} ,
  pre = {empty = false} ,
  q = {empty = false} ,
  s =  {empty = false} ,
  samp = {empty = false} ,
  script = {empty = false} ,
  select = {empty = false} ,
  small = {empty = false} ,
  span = {empty = false} ,
  strike = {empty = false} ,
  strong = {empty = false} ,
  style = {empty = false} ,
  sub = {empty = false} ,
  sup = {empty = false} ,
  table = {empty = false} ,
  tbody = {empty = false} ,
  td = {
    empty = false,
    optional_end = true,
    child = {
      inline,
      block,
      "del",
      "ins",
      "noscript",
      "script",
    },
  },
  textarea = {empty = false} ,
  tfoot = {
    empty = false,
    optional_end = true,
    child = {"tr",},
  },
  th = {
    empty = false,
    optional_end = true,
    child = {
      inline,
      block,
      "del",
      "ins",
      "noscript",
      "script",
    },
  },
  thead = {
    empty = false,
    optional_end = true,
    child = {"tr",},
  },
  title = {empty = false} ,
  tr = {
    empty = false,
    optional_end = true,
    child = {
      "td", "th",
    },
  },
  tt = {empty = false} ,
  u = {empty = false} ,
  ul = {empty = false} ,
  var = {empty = false} ,
}

setmetatable(tags, {
  __index = function (t, key)
    return {empty = false}
  end
})

-- string buffer implementation
function newbuf ()
  local buf = {
    _buf = {},
    clear =   function (self) self._buf = {}; return self end,
    content = function (self) return table.concat(self._buf) end,
    append =  function (self, s)
      self._buf[#(self._buf) + 1] = s
      return self
    end,
    set =     function (self, s) self._buf = {s}; return self end,
  }
  return buf
end

-- unescape character entities
function unescape (s)
  function entity2string (e)
    return entity[e]
  end
  return s.gsub(s, "&(#?%w+);", entity2string)
end

-- iterator factory
function makeiter (f)
  local co = coroutine.create(f)
  return function ()
    local code, res = coroutine.resume(co)
    return res
  end
end

-- constructors for token
function Tag (s) 
  return string.find(s, "^</") and
    {type = "End",   value = s} or
    {type = "Start", value = s}
end

function Text (s)
  local unescaped = unescape(s) 
  return {type = "Text", value = unescaped} 
end

-- lexer: text mode
function text (f, buf)
  local c = f:read(1)
  if c == "<" then
    if buf:content() ~= "" then coroutine.yield(Text(buf:content())) end
    buf:set(c)
    return tag(f, buf)
  elseif c then
    buf:append(c)
    return text(f, buf)
  else
    if buf:content() ~= "" then coroutine.yield(Text(buf:content())) end
  end
end

-- lexer: tag mode
function tag (f, buf)
  local c = f:read(1)
  if c == ">" then
    coroutine.yield(Tag(buf:append(c):content()))
    buf:clear()
    return text(f, buf)
  elseif c then
    buf:append(c)
    return tag(f, buf)
  else
    if buf:content() ~= "" then coroutine.yield(Tag(buf:content())) end
  end
end

function parse_starttag(tag)
  local tagname = string.match(tag, "<%s*(%w+)")
  local elem = {_attr = {}}
  elem._tag = tagname
  for key, _, val in string.gmatch(tag, "(%w+)%s*=%s*([\"'])(.-)%2", i) do
    local unescaped = unescape(val)
    elem._attr[key] = unescaped
  end
  return elem
end

function parse_endtag(tag)
  local tagname = string.match(tag, "<%s*/%s*(%w+)")
  return tagname
end

-- find last element that satisfies given predicate
function rfind(t, pred)
  local length = #t
  for i=length,1,-1 do
    if pred(t[i]) then
      return i, t[i]
    end
  end
end

function flatten(t, acc)
  acc = acc or {}
  for i,v in ipairs(t) do
    if type(v) == "table" then
      flatten(v, acc)
    else
      acc[#acc + 1] = v
    end
  end
  return acc
end

function optional_end_p(elem)
  if tags[elem._tag].optional_end then
    return true
  else
    return false
  end
end

function valid_child_p(child, parent)
  local schema = tags[parent._tag].child
  if not schema then return true end

  for i,v in ipairs(flatten(schema)) do
    if v == child._tag then
      return true
    end
  end

  return false
end

-- tree builder
function parse(f)
  local documentRoot = {_tag = "#document", _attr = {}}
  local stack = {documentRoot}
  for i in makeiter(function () return text(f, newbuf()) end) do
    if i.type == "Start" then
      local new = parse_starttag(i.value)
      local top = stack[#stack]

      while
        top._tag ~= "#document" and 
        optional_end_p(top) and
        not valid_child_p(new, top)
      do
        stack[#stack] = nil 
        top = stack[#stack]
      end

      top[#top+1] = new -- appendchild
      if not tags[new._tag].empty then 
        stack[#stack+1] = new -- push
      end
    elseif i.type == "End" then
      local tag = parse_endtag(i.value)
      local openingpos = rfind(stack, function(v) 
          if v._tag == tag then
            return true
          else
            return false
          end
        end)
      if openingpos then
        local length = #stack
        for j=length,openingpos,-1 do
          table.remove(stack, j)
        end
      end
    else -- Text
      local top = stack[#stack]
      top[#top+1] = i.value
    end
  end
  return documentRoot
end

function parsestr(s)
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
  return parse(handle)
end


g_htmlColorTable = {
	aliceblue 				= '#F0F8FF',
	antiquewhite 			= '#FAEBD7',
	aqua 					= '#00FFFF',
	aquamarine 				= '#7FFFD4',
	azure 					= '#F0FFFF',
	beige 					= '#F5F5DC',
	bisque 					= '#FFE4C4',
	black 					= '#000000',
	blanchedalmond 			= '#FFEBCD',
	blue 					= '#0000FF',
	blueviolet 				= '#8A2BE2',
	brown 					= '#A52A2A',
	burlywood 				= '#DEB887',
	cadetblue 				= '#5F9EA0',
	chartreuse 				= '#7FFF00',
	chocolate 				= '#D2691E',
	coral 					= '#FF7F50',
	cornflowerblue 			= '#6495ED',
	cornsilk 				= '#FFF8DC',
	crimson 				= '#DC143C',
	cyan 					= '#00FFFF',
	darkblue 				= '#00008B',
	darkcyan 				= '#008B8B',
	darkgoldenrod 			= '#B8860B',
	darkgray 				= '#A9A9A9',
	darkgreen 				= '#006400',
	darkkhaki 				= '#BDB76B',
	darkmagenta 			= '#8B008B',
	darkolivegreen 			= '#556B2F',
	darkorange 				= '#FF8C00',
	darkorchid 				= '#9932CC',
	darkred 				= '#8B0000',
	darksalmon 				= '#E9967A',
	darkseagreen 			= '#8FBC8F',
	darkslateblue 			= '#483D8B',
	darkslategray 			= '#2F4F4F',
	darkturquoise 			= '#00CED1',
	darkviolet 				= '#9400D3',
	deeppink 				= '#FF1493',
	deepskyblue 			= '#00BFFF',
	dimgray 				= '#696969',
	dimgrey 				= '#696969',
	dodgerblue 				= '#1E90FF',
	firebrick 				= '#B22222',
	floralwhite 			= '#FFFAF0',
	forestgreen 			= '#228B22',
	fuchsia 				= '#FF00FF',
	gainsboro 				= '#DCDCDC',
	ghostwhite 				= '#F8F8FF',
	gold 					= '#FFD700',
	goldenrod 				= '#DAA520',
	gray 					= '#808080',
	green 					= '#008000',
	greenyellow 			= '#ADFF2F',
	honeydew 				= '#F0FFF0',
	hotpink 				= '#FF69B4',
	indianred  				= '#CD5C5C',
	indigo  				= '#4B0082',
	ivory 					= '#FFFFF0',
	khaki 					= '#F0E68C',
	lavender 				= '#E6E6FA',
	lavenderblush 			= '#FFF0F5',
	lawngreen 				= '#7CFC00',
	lemonchiffon 			= '#FFFACD',
	lightblue 				= '#ADD8E6',
	lightcoral 				= '#F08080',
	lightcyan 				= '#E0FFFF',
	lightgoldenrodyellow	= '#FAFAD2',
	lightgray 				= '#D3D3D3',
	lightgreen 				= '#90EE90',
	lightpink 				= '#FFB6C1',
	lightsalmon 			= '#FFA07A',
	lightseagreen 			= '#20B2AA',
	lightskyblue 			= '#87CEFA',
	lightslategray 			= '#778899',
	lightsteelblue 			= '#B0C4DE',
	lightyellow 			= '#FFFFE0',
	lime 					= '#00FF00',
	limegreen 				= '#32CD32',
	linen 					= '#FAF0E6',
	magenta 				= '#FF00FF',
	maroon 					= '#800000',
	mediumaquamarine 		= '#66CDAA',
	mediumblue 				= '#0000CD',
	mediumorchid 			= '#BA55D3',
	mediumpurple 			= '#9370DB',
	mediumseagreen 			= '#3CB371',
	mediumslateblue 		= '#7B68EE',
	mediumspringgreen 		= '#00FA9A',
	mediumturquoise 		= '#48D1CC',
	mediumvioletred 		= '#C71585',
	midnightblue 			= '#191970',
	mintcream 		 		= '#F5FFFA',
	mistyrose 				= '#FFE4E1',
	moccasin 				= '#FFE4B5',
	navajowhite 			= '#FFDEAD',
	navy 					= '#000080',
	oldlace 				= '#FDF5E6',
	olive 					= '#808000',
	olivedrab 				= '#6B8E23',
	orange 					= '#FFA500',
	orangered 				= '#FF4500',
	orchid 					= '#DA70D6',
	palegoldenrod 			= '#EEE8AA',
	palegreen 				= '#98FB98',
	paleturquoise 			= '#AFEEEE',
	palevioletred 			= '#DB7093',
	papayawhip 				= '#FFEFD5',
	peachpuff 				= '#FFDAB9',
	peru 					= '#CD853F',
	pink 					= '#FFC0CB',
	plum 					= '#DDA0DD',
	powderblue 				= '#B0E0E6',
	purple 					= '#800080',
	red 					= '#FF0000',
	rosybrown 				= '#BC8F8F',
	royalblue 				= '#4169E1',
	saddlebrown 			= '#8B4513',
	salmon 					= '#FA8072',
	sandybrown 				= '#F4A460',
	seagreen 				= '#2E8B57',
	seashell 				= '#FFF5EE',
	sienna 					= '#A0522D',
	silver 					= '#C0C0C0',
	skyblue 				= '#87CEEB',
	slateblue 				= '#6A5ACD',
	slategray 				= '#708090',
	snow 					= '#FFFAFA',
	springgreen 			= '#00FF7F',
	steelblue 				= '#4682B4',
	tan 					= '#D2B48C',
	teal 					= '#008080',
	thistle 				= '#D8BFD8',
	tomato 					= '#FF6347',
	turquoise 				= '#40E0D0',
	violet 					= '#EE82EE',
	wheat 					= '#F5DEB3',
	white 					= '#FFFFFF',
	whitesmoke 				= '#F5F5F5',
	yellow 					= '#FFFF00',
	yellowgreen 			= '#9ACD32',
}