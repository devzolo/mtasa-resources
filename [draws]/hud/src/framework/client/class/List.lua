local super = Class("List", Component, function()
	static.base = "list"
	static.nameCounter = 0
	static.DEFAULT_VISIBLE_ROWS = 4
	
	static.constructComponentName = function()
		static.nameCounter = static.nameCounter + 1
        return static.base .. tostring(static.nameCounter);
    end	
end).getSuperclass()


function List:init(rows, multipleMode)
	super.init(self)
	self.items = ArrayList()
	self.rows = rows and rows ~= 0 and rows or List.DEFAULT_VISIBLE_ROWS
	self.multipleMode = multipleMode or false
	self.selected = {}
    self.visibleIndex = -1;
    self.actionListener = nil
    self.itemListener = nil
	return self
end

function List:getItemCount()
    return self.items:size()
end

function List:getItem(index)
	return self.items:elementAt(index)
end

function List:getItems()
	local itemCopies = {}
	for k,v in pairs(self.items) do
		table.insert(itemCopies, v)
	end
	return itemCopies
end


function List:add(item, index)
	if (index < -1 or index >= self.items:size()) then
		index = -1
	end

	if (item == nil) then
		item = ""
	end

	if (index == -1) then
		items:addElement(item)
	else
		items:insertElementAt(item, index)
	end
end

function List:replaceItem(newValue, index)
	self:remove(index);
	self:add(newValue, index);
end

function List:removeAll()
    self.items = ArrayList()
    self.selected = {}
end

function List:removeByValue(item)
	local index = self.items:indexOf(item)
	if (index < 0) then
		throw('IllegalArgumentException("item ' .. item ..  ' not found in list")')
	else
		self:remove(index)
	end
end
	
function List:remove(startPos, endPos)
    for i = endPos or startPos, startPos do
       self.items:removeElementAt(i)
    end
end

function List:getSelectedIndex()
	local sel = self:getSelectedIndexes()
	if(#sel == 1) then
		return sel[1] 
	end
	return -1
end

function List:getSelectedIndexes()
	return self.selected:clone()
end

function List:getSelectedItem()
	local index = self:getSelectedIndex()
	if(index < 0) then	
		return nil
	end 
	return self:getItem(index)
end

function List:getSelectedItems()
	local sel = self:getSelectedIndexes()
	local str = {}
	for i = 0 , #sel do
		table.insert(str, i, self:getItem(sel[i]))
	end
	return str
end

function List:select(index) 
	local alreadySelected = false

	for  i = 1 , #self.selected do
		if (self.selected[i] == index) then
			alreadySelected = true
			break
		end
	end

	if (not alreadySelected) then
		if (not multipleMode) then
			self.selected = {}
			table.insert(self.selected, 1, index)
		else
			table.insert(self.selected, #self.selected, index)
		end
	end
end

function List:deselect(index) 
	for  i = 1 , #self.selected do
		if (self.selected[i] == index) then
			table.remove(self.selected, i)
			return;
		end
	end
end

function List:isIndexSelected(index) 
	local sel = self:getSelectedIndexes()
	for  i = 1 , #sel do
		if (sel[i] == index) then
			return true
		end
	end
	return false
end
