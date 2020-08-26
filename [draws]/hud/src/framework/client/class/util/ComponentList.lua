local super = Class("ComponentList", ArrayList).getSuperclass()

function ComponentList.checkComponent(c)
	return instanceOf(c, Component)
end

function ComponentList:init()
	super.init(self, ComponentList.checkComponent, true)
	return self
end

function ComponentList:orderBy(by, order)
	local components = {}
	for k, v in pairs(self.table) do
		table.insert(components, v)
	end
	table.sort(components, function( a , b)
		if(order == "desc") then
			return a[by] > b[by]
		else
			return a[by] < b[by]
		end
	end)
	return components
end



