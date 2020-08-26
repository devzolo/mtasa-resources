local super = Class("AdjustmentEvent", Event).getSuperclass()

AdjustmentEvent.ADJUSTMENT_FIRST = 601
AdjustmentEvent.ADJUSTMENT_LAST = 601
AdjustmentEvent.ADJUSTMENT_VALUE_CHANGED = AdjustmentEvent.ADJUSTMENT_FIRST
AdjustmentEvent.UNIT_INCREMENT	= 1
AdjustmentEvent.UNIT_DECREMENT	= 2
AdjustmentEvent.BLOCK_DECREMENT = 3
AdjustmentEvent.BLOCK_INCREMENT = 4
AdjustmentEvent.TRACK	        = 5

function AdjustmentEvent:init(source, id,  type, value, isAdjusting)
	super.init(self, source, id)
    self.adjustable = source
    self.value = value
	self.adjustmentType = type
	self.isAdjusting = isAdjusting
	return self
end

function AdjustmentEvent:getAdjustable()
	return self.adjustable;
end

function AdjustmentEvent:getValue()
	return self.value
end

function AdjustmentEvent:getAdjustmentType()
	return self.adjustmentType
end

function AdjustmentEvent:getValueIsAdjusting()
	return self.isAdjusting
end
