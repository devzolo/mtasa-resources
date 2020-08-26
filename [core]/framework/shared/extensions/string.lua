local stringCleanMap = {
	['ã'] = 'a',
	['é'] = 'e',
}

function string.clean(str)
	local result = string.gsub(str,"([%z\1-\127\194-\244][\128-\191]*)", function(c)
		return stringCleanMap[c] or c
	end)
	return result
end

function string.utfChar(c)
	return utfChar(c)
end

function string.utfCode(c)
	return utfCode(c)
end

function string.utfLen(str)
	return utfLen(str)
end

function string.utfSeek(str, Start, End)
	return utfSeek(str, Start, End)
end

function string.utfSub(str, Start, End)
	return utfSub(str, Start, End or Start)
end

function string.utfReverse(str)
	local result = ""
	for i = str:utfLen(), 1, -1 do
		result = result .. utfSub(str, i, i)
	end
	return result
end

function string.toTable ( str )

	local tab = {}

	for i=1, string.len( str ) do
		table.insert( tab, string.sub( str, i, i ) )
	end

	return tab

end

function string.explode ( seperator, str )

	if ( seperator == "" ) then
		return string.toTable( str )
	end

	local tble={}
	local ll=0

	while (true) do

		l = string.find( str, seperator, ll, true )

		if (l ~= nil) then
			table.insert(tble, string.sub(str,ll,l-1))
			ll=l+1
		else
			table.insert(tble, string.sub(str,ll))
			break
		end

	end

	return tble

end

function string.implode(seperator,Table) return
	table.concat(Table,seperator)
end

function string.getExtensionFromFilename(path)
	local ExplTable = string.toTable( path )
	for i = table.getn(ExplTable), 1, -1 do
		if ExplTable[i] == "." then return string.sub(path, i+1)end
		if ExplTable[i] == "/" or ExplTable[i] == "\\" then return "" end
	end
	return ""
end

function string.getPathFromFilename(path)
	local ExplTable = string.toTable( path )
	for i = table.getn(ExplTable), 1, -1 do
		if ExplTable[i] == "/" or ExplTable[i] == "\\" then return string.sub(path, 1, i) end
	end
	return ""
end

function string.getFileFromFilename(path)
	local ExplTable = string.toTable( path )
	for i = table.getn(ExplTable), 1, -1 do
		if ExplTable[i] == "/" or ExplTable[i] == "\\" then return string.sub(path, i) end
	end
	return ""
end

function string.formattedTime( TimeInSeconds, Format )
	if not TimeInSeconds then TimeInSeconds = 0 end

	local i = math.floor( TimeInSeconds )
	local h,m,s,ms	=	( i/3600 ),
				( i/60 )-( math.floor( i/3600 )*3600 ),
				TimeInSeconds-( math.floor( i/60 )*60 ),
				( TimeInSeconds-i )*100

	if Format then
		return string.format( Format, m, s, ms )
	else
		return { h=h, m=m, s=s, ms=ms }
	end
end

function string.toMinutesSecondsMilliseconds( TimeInSeconds )
	return string.formattedTime( TimeInSeconds, "%02i:%02i:%02i")
end

function string.toMinutesSeconds( TimeInSeconds )
	return string.FormattedTime( TimeInSeconds, "%02i:%02i")
end

function string.left(str, num)
	return string.sub(str, 1, num)
end

function string.right(str, num)
	return string.sub(str, -num)
end

function string.replace(str, tofind, toreplace)
	local start = 1
	while (true) do
		local pos = string.find(str, tofind, start, true)

		if (pos == nil) then
			break
		end

		local left = string.sub(str, 1, pos-1)
		local right = string.sub(str, pos + #tofind)

		str = left .. toreplace .. right
		start = pos + #toreplace
	end
	return str
end

function string.trim( s, char )
	if (char==nil) then char = "%s" end
	return string.gsub(s, "^".. char.."*(.-)"..char.."*$", "%1")
end

function string.trimRight( s, char )

	if (char==nil) then char = " " end

	if ( string.sub( s, -1 ) == char ) then
		s = string.sub( s, 0, -2 )
		s = string.trimRight( s, char )
	end

	return s

end

function string.trimLeft( s, char )

	if (char==nil) then char = " " end

	if ( string.sub( s, 1 ) == char ) then
		s = string.sub( s, 1 )
		s = string.trimLeft( s, char )
	end

	return s

end

