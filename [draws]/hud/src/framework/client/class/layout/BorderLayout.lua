local super = Class("BorderLayout", LayoutManager).getSuperclass()

BorderLayout.NORTH  = "North"
BorderLayout.SOUTH  = "South"
BorderLayout.EAST   = "East"
BorderLayout.WEST   = "West"
BorderLayout.CENTER = "Center"
BorderLayout.BEFORE_FIRST_LINE = "First"
BorderLayout.AFTER_LAST_LINE = "Last"
BorderLayout.BEFORE_LINE_BEGINS = "Before"
BorderLayout.AFTER_LINE_ENDS = "After"
BorderLayout.PAGE_START = BorderLayout.BEFORE_FIRST_LINE
BorderLayout.PAGE_END = BorderLayout.AFTER_LAST_LINE
BorderLayout.LINE_START = BorderLayout.BEFORE_LINE_BEGINS
BorderLayout.LINE_END = BorderLayout.AFTER_LINE_ENDS

function BorderLayout:init()
	super.init(self)
	return self
end

function BorderLayout:getLayoutComponent(constraints)
	if (BorderLayout.CENTER == constraints) then
		return center
	elseif(BorderLayout.NORTH == constraints) then
		return north
	elseif(BorderLayout.SOUTH == constraints) then
		return south
	elseif (BorderLayout.WEST == constraints) then
		return west
	elseif(BorderLayout.EAST == constraints) then
		return east
	elseif(BorderLayout.PAGE_START == constraints) then
		return firstLine
	elseif(BorderLayout.PAGE_END == constraints) then
		return lastLine
	elseif(BorderLayout.LINE_START == constraints) then
		return firstItem
	elseif (BorderLayout.LINE_END == constraints) then
		return lastItem
	else 
		outputDebugString("cannot get component: unknown constraint: " .. constraints)
	end
end
