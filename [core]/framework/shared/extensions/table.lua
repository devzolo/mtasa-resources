function table.inherit( t, base )

	for k, v in pairs( base ) do 
		if ( t[k] == nil ) then	t[k] = v end
	end
	
	t["BaseClass"] = base
	
	return t

end

function table.copy(t, lookup_table)
	if (t == nil) then return nil end
	
	local copy = {}
	setmetatable(copy, getmetatable(t))
	for i,v in pairs(t) do
		if type(v) ~= "table" then
			copy[i] = v
		else
			lookup_table = lookup_table or {}
			lookup_table[t] = copy
			if lookup_table[v] then
				copy[i] = lookup_table[v] -- we already copied this table. reuse the copy.
			else
				copy[i] = table.copy(v,lookup_table) -- not yet copied. copy it.
			end
		end
	end
	return copy
end

function table.empty( tab )

	for k, v in pairs( tab ) do
		tab[k] = nil
	end

end

function table.copyFromTo( FROM, TO )

	-- Erase values from table TO
	table.empty( TO )
	
	-- Copy values over
	table.merge( TO, FROM )
	
end

function table.merge(dest, source)

	for k,v in pairs(source) do
	
		if ( type(v) == 'table' and type(dest[k]) == 'table' ) then
			-- don't overwrite one table with another;
			-- instead merge them recurisvely
			table.merge(dest[k], v)
		else
			dest[k] = v
		end
	end
	
	return dest
	
end

function table.hasValue( t, val )
	for k,v in pairs(t) do
		if (v == val ) then return true end
	end
	return false
end

--table.inTable = hasValue

function table.add( dest, source )

	-- At least one of them needs to be a table or this whole thing will fall on its ass
	if (type(source)~='table') then return dest end
	
	if (type(dest)~='table') then dest = {} end

	for k,v in pairs(source) do
		table.insert( dest, v )
	end
	
	return dest
end

function table.sortdesc( Table )

	return table.sort( Table, function(a, b) return a > b end )
end

function table.sortByKey( Table, Desc )

	local temp = {}

	for key, _ in pairs(Table) do table.insert(temp, key) end
	if ( Desc ) then
		table.sort(temp, function(a, b) return Table[a] < Table[b] end)
	else
		table.sort(temp, function(a, b) return Table[a] > Table[b] end)
	end

	return temp
end

function table.count (t)
  local i = 0
  for k in pairs(t) do i = i + 1 end
  return i
end

function table.random (t)
  
  local rk = math.random( 1, table.count( t ) )
  local i = 1
  for k, v in pairs(t) do 
	if ( i == rk ) then return v end
	i = i + 1 
  end

end

function table.isSequential(t)
	local i = 1
	for key, value in pairs (t) do
		if not tonumber(i) or key ~= i then return false end
		i = i + 1
	end
	return true
end

function table.toString(t,n,nice)
	local 		nl,tab  = "",  ""
	if nice then 	nl,tab = "\n", "\t"	end

	local function makeTable ( t, nice, indent, done)
		local str = ""
		local done = done or {}
		local indent = indent or 0
		local idt = ""
		if nice then idt = string.rep ("\t", indent) end

		local sequential = table.isSequential(t)

		for key, value in pairs (t) do

			str = str .. idt .. tab .. tab

			if not sequential then
				if type(key) == "number" or type(key) == "boolean" then 
					key ='['..tostring(key)..']' ..tab..'='
				else
					key = tostring(key) ..tab..'='
				end
			else
				key = ""
			end

			if type (value) == "table" and not done [value] then

				done [value] = true
				str = str .. key .. tab .. '{' .. nl
				.. makeTable (value, nice, indent + 1, done)
				str = str .. idt .. tab .. tab ..tab .. tab .."},".. nl

			else
				
				if 	type(value) == "string" then 
					value = '"'..tostring(value)..'"'
				elseif  type(value) == "Vector" then
					value = 'Vector('..value.x..','..value.y..','..value.z..')'
				elseif  type(value) == "Angle" then
					value = 'Angle('..value.pitch..','..value.yaw..','..value.roll..')'
				else
					value = tostring(value)
				end
				
				str = str .. key .. tab .. value .. ",".. nl

			end

		end
		return str
	end
	local str = ""
	if n then str = n.. tab .."=" .. tab end
	str = str .."{" .. nl .. makeTable ( t, nice) .. "}"
	return str
end

function table.sanitise( t, done )

	local done = done or {}
	local tbl = {}

	for k, v in pairs ( t ) do
	
		if ( type( v ) == "table" and not done[ v ] ) then

			done[ v ] = true
			tbl[ k ] = table.sanitise ( v, done )

		else

			if ( type(v) == "Vector" ) then

				local x, y, z = v.x, v.y, v.z
				if y == 0 then y = nil end
				if z == 0 then z = nil end
				tbl[k] = { __type = "Vector", x = x, y = y, z = z }

			elseif ( type(v) == "Angle" ) then

				local p,y,r = v.pitch, v.yaw, v.roll
				if p == 0 then p = nil end
				if y == 0 then y = nil end
				if r == 0 then r = nil end
				tbl[k] = { __type = "Angle", p = p, y = y, r = r }

			elseif ( type(v) == "boolean" ) then
			
				tbl[k] = { __type = "Bool", tostring( v ) }

			else
			
				tbl[k] = tostring(v)

			end
			
			
		end
		
		
	end
	
	return tbl
	
end

function table.deSanitise( t, done )

	local done = done or {}
	local tbl = {}

	for k, v in pairs ( t ) do
	
		if ( type( v ) == "table" and not done[ v ] ) then
		
			done[ v ] = true

			if ( v.__type ) then
			
				if ( v.__type == "Vector" ) then
				
					tbl[ k ] = Vector( v.x, v.y, v.z )
				
				elseif ( v.__type == "Angle" ) then
				
					tbl[ k ] = Angle( v.p, v.y, v.r )
					
				elseif ( v.__type == "Bool" ) then
					
					tbl[ k ] = ( v[1] == "true" )
					
				end
			
			else
			
				tbl[ k ] = table.deSanitise( v, done )
				
			end
			
		else
		
			tbl[ k ] = v
			
		end
		
	end
	
	return tbl
	
end

function table.forceInsert( t, v )

	if ( t == nil ) then t = {} end
	
	table.insert( t, v )
	
end

function table.sortByMember( Table, MemberName, bAsc )

	local tableMemberSort = function( a, b, MemberName, bReverse ) 
	
		-- All this error checking kind of sucks, but really is needed
		if ( type(a) ~= "table" ) then return not bReverse end
		if ( type(b) ~= "table" ) then return bReverse end
		if ( not a[MemberName] ) then return not bReverse end
		if ( not b[MemberName] ) then return bReverse end
	
		if ( bReverse ) then
			return a[MemberName] < b[MemberName]
		else
			return a[MemberName] > b[MemberName]
		end
		
	end

	table.sort( Table, function(a, b) return tableMemberSort( a, b, MemberName, bAsc or false ) end )
	
end

function table.lowerKeyNames( Table )

	local OutTable = {}

	for k, v in pairs( Table ) do
	
		-- Recurse
		if ( type( v ) == "table" ) then
			v = table.lowerKeyNames( v )
		end
		
		OutTable[ k ] = v
		
		if ( type( k ) == "string" ) then
	
			OutTable[ k ]  = nil
			OutTable[ string.lower( k ) ] = v
		
		end		
	
	end
	
	return OutTable
	
end

function table.collapseKeyValue( Table )

	local OutTable = {}
	
	for k, v in pairs( Table ) do
	
		local Val = v.Value
	
		if ( type( Val ) == "table" ) then
			Val = table.collapseKeyValue( Val )
		end
		
		OutTable[ v.Key ] = Val
	
	end
	
	return OutTable

end

function table.clearKeys( Table, bSaveKey )

	local OutTable = {}
	
	for k, v in pairs( Table ) do
		if ( bSaveKey ) then
			v.__key = k
		end
		table.insert( OutTable, v )	
	end
	
	return OutTable

end



local function fnPairsSorted( pTable, Index )

	if ( Index == nil ) then
	
		Index = 1
	
	else
	
		for k, v in pairs( pTable.__SortedIndex ) do
			if ( v == Index ) then
				Index = k + 1
				break
			end
		end
		
	end
	
	local Key = pTable.__SortedIndex[ Index ]
	if ( not Key ) then
		pTable.__SortedIndex = nil
		return
	end
	
	Index = Index + 1
	
	return Key, pTable[ Key ]

end

function sortedPairs( pTable, Desc )

	pTable = table.copy( pTable )
	
	local SortedIndex = {}
	for k, v in pairs( pTable ) do
		table.insert( SortedIndex, k )
	end
	
	if ( Desc ) then
		table.sort( SortedIndex, function(a,b) return a>b end )
	else
		table.sort( SortedIndex )
	end
	pTable.__SortedIndex = SortedIndex

	return fnPairsSorted, pTable, nil
	
end

function sortedPairsByValue( pTable, Desc )

	pTable = table.clearKeys( pTable )
	
	if ( Desc ) then
		table.sort( pTable, function(a,b) return a>b end )
	else
		table.sort( pTable )
	end

	return ipairs( pTable )
	
end

function sortedPairsByMemberValue( pTable, pValueName, Desc )

	Desc = Desc or false
	
	local pSortedTable = table.clearKeys( pTable, true )
	
	table.sortByMember( pSortedTable, pValueName, not Desc )
	
	local SortedIndex = {}
	for k, v in ipairs( pSortedTable ) do
		table.insert( SortedIndex, v.__key )
	end
	
	pTable.__SortedIndex = SortedIndex

	return fnPairsSorted, pTable, nil
	
end


function randomPairs( pTable, Desc )

	local Count = table.count( pTable )
	pTable = table.copy( pTable )
	
	local SortedIndex = {}
	for k, v in pairs( pTable ) do
		table.insert( SortedIndex, { key = k, val = math.random( 1, 1000 ) } )
	end
	
	if ( Desc ) then
		table.sort( SortedIndex, function(a,b) return a.val>b.val end )
	else
		table.sort( SortedIndex, function(a,b) return a.val<b.val end )
	end
	
	for k, v in pairs( SortedIndex ) do
		SortedIndex[ k ] = v.key;
	end
	
	pTable.__SortedIndex = SortedIndex

	return fnPairsSorted, pTable, nil
	
end

function table.getFirstKey( t )

	local k, v = next( t )
	return k
	
end

function table.getFirstValue( t )

	local k, v = next( t )
	return v
	
end

function table.getLastKey( t )

	local k, v = next( t, table.count(t) )
	return k
	
end

function table.getLastValue( t )

	local k, v = next( t, table.count(t) )
	return v
	
end

function table.findNext( tab, val )
	
	local bfound = false
	for k, v in pairs( tab ) do
		if ( bfound ) then return v end
		if ( val == v ) then bfound = true end
	end
	
	return table.getFirstValue( tab )	
	
end

function table.findPrev( tab, val )
	
	local last = table.getLastValue( tab )
	for k, v in pairs( tab ) do
		if ( val == v ) then return last end
		last = v
	end
	
	return last
	
end

function table.getWinningKey( tab )
	
	local highest = -10000
	local winner = nil
	
	for k, v in pairs( tab ) do
		if ( v > highest ) then 
			winner = k
			highest = v
		end
	end
	
	return winner
	
end

function table.find(tableToSearch, index, value)
    if not value then
        value = index
        index = false
    elseif value == '[nil]' then
        value = nil
    end
    for k,v in pairs(tableToSearch) do
        if index then
            if v[index] == value then
                return k
            end
        elseif v == value then
            return k
        end
    end
    return false
end

function table.removevalue(t, val)
    for i,v in ipairs(t) do
        if v == val then
            table.remove(t, i)
            return i
        end
    end
    return false
end

function table.each(t, index, callback, ...)
    local args = { ... }
    if type(index) == 'function' then
        table.insert(args, 1, callback)
        callback = index
        index = false
    end
    for k,v in pairs(t) do
        callback(index and v[index] or v, unpack(args))
    end
    return t
end

function table.deepcopy(t)
    local known = {}
    local function _deepcopy(t)
        local result = {}
        for k,v in pairs(t) do
            if type(v) == 'table' then
                if not known[v] then
                    known[v] = _deepcopy(v)
                end
                result[k] = known[v]
            else
                result[k] = v
            end
        end
        return result
    end
    return _deepcopy(t)
end 

function table.create(keys, vals)
    local result = {}
    if type(vals) == 'table' then
        for i,k in ipairs(keys) do
            result[k] = vals[i]
        end
    else
        for i,k in ipairs(keys) do
            result[k] = vals
        end
    end
    return result
end

function table.insertUnique(t,val)
    if not table.find(t, val) then
        table.insert(t,val)
        return true
    end
    return false
end

function table.popLast(t,val)
    if #t==0 then
        return false
    end
    local last = t[#t]
    table.remove(t)
    return last
end