local super = Class("PasswordField", TextField).getSuperclass()

PasswordField.nameCounter = 0

function PasswordField:init(text, columns)
	super.init(self, text, columns)
	self:setEchoChar("●")
	return self
end

function PasswordField:getEchoChar()
	return self.echoChar
end

function PasswordField:setEchoChar(c)
	self.echoChar = c
end

function PasswordField:getEchoText()
	return string.gsub(self.text,".", self:getEchoChar())
end
