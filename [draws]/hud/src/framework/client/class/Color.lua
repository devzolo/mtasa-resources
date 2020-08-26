local super = Class("Color", LuaObject).getSuperclass()

Transparency = {
	OPAQUE = 1,
	BITMASK = 2,
	TRANSLUCENT = 3,
}

Color.FACTOR = 0.7
 
function Color:init(r,g,b,a)
	super.init(self)
	if(instanceOf(r,Color)) then
		self.value = r.value
	else
		self.value = tocolor(r or 0,g or 0, b or 0,a or 255)
	end
	return self
end

function Color:brighter()
	local r = self:getRed()
	local g = self:getGreen()
	local b = self:getBlue()
	local alpha = self:getAlpha()

	local i = 1.0/(1.0-Color.FACTOR)
	if ( r == 0 and g == 0 and b == 0) then
		return Color(i, i, i, alpha)
	end
	
	if ( r > 0 and r < i ) then r = i end
	if ( g > 0 and g < i ) then g = i end
	if ( b > 0 and b < i ) then b = i end

	return Color( math.min(r/Color.FACTOR, 255),
							 math.min(g/Color.FACTOR, 255),
							 math.min(b/Color.FACTOR, 255),
							 alpha)
end
	
function Color:darker()
	return Color(math.max(self:getRed()*Color.FACTOR, 0),
							math.max(self:getGreen()*Color.FACTOR, 0),
							math.max(self:getBlue()*Color.FACTOR, 0),
							self:getAlpha());
end

function Color:getRed()
	return bitAnd(bitRShift(self:getRGB(),16),0xff)
end

function Color:getGreen()
	return bitAnd(bitRShift(self:getRGB(),8),0xff)
end

function Color:getBlue()
	return bitAnd(bitRShift(self:getRGB(),0),0xff)
end


function Color:getAlpha()
	return bitAnd(bitRShift(self:getRGB(),24),0xff)
end

function Color:getRGB()
	return self.value
end
	
function Color:getTransparency()
	local alpha = self:getAlpha()
	if (alpha == 0xff) then
		return Transparency.OPAQUE
	elseif(alpha == 0) then
		return Transparency.BITMASK
	else 
		return Transparency.TRANSLUCENT
	end
end

function Color.toColorValue(r, g, b, a)
	if(g and b) then
		return tocolor(r, g, b, a)
	elseif(type(r) == "number") then
		return r
	elseif(type(r) == "string") then
		return tocolor(getColorFromString(r))
	elseif(instanceOf(r, Color)) then
		return r.value
	else
		return r
	end
end

Color.white = Color(255, 255, 255)
Color.WHITE = white
Color.lightGray = Color(192, 192, 192)
Color.LIGHT_GRAY = lightGray
Color.gray = Color(128, 128, 128)
Color.GRAY = gray 
Color.darkGray = Color(64, 64, 64)
Color.DARK_GRAY = darkGray
Color.black = Color(0, 0, 0)
Color.BLACK = black
Color.red = Color(255, 0, 0)
Color.RED = red
Color.pink = Color(255, 175, 175)
Color.PINK = pink
Color.orange = Color(255, 200, 0)
Color.ORANGE = orange
Color.yellow = Color(255, 255, 0)
Color.YELLOW = yellow
Color.green = Color(0, 255, 0)
Color.GREEN = green
Color.magenta = Color(255, 0, 255)
Color.MAGENTA = magenta
Color.cyan = Color(0, 255, 255)
Color.CYAN = cyan
Color.blue = Color(0, 0, 255)
Color.BLUE = blue



