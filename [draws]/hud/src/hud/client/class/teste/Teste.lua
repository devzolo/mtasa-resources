local super = Class("Teste", Panel, function()
  static.getInstance = function()
    return LuaObject.getSingleton(static)
  end
end).getSuperclass()

function Teste:init()
  super.init(self)

  self:setBounds(0, 300, 300, 200)
  self:setBackground(tocolor(0, 0, 0, 150))
  return self
end
