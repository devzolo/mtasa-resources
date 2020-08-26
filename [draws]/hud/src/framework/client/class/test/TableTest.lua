local super = Class("TableTest", Panel).getSuperclass()

function TableTest:init()
	super.init(self)
	
	self:css([[
		button {
			color: #FFFFFF;
			background-color: #FD9A34;
			cursor: pointer;
		}
		button:hover {
			color: #FFFFFF;
			background-color: #F0871A;
			cursor: pointer;
		}
		button:active{
			color: #FFFFFF;
			background-color: #FF8100;
			cursor: pointer;
		}				
		button:focus {
			color: #FFFFFF;
			background-color: #F0871A;
			cursor: pointer;
		}
		button:disabled {
			background-color: #eaeaea;
			color: #bebebe;
			cursor: not-allowed;
		}
		
	
		table {
		  color: #0000;
		  background-color: #0A0A0A;
		}

		th {
		  background-color: #000000;
		  color: #FF6000;
		}
		  
		th:hover {
		  background-color: #000000;
		  color: #FF6000;
		} 

		td {
		  background-color: #0000;
		  color: #FFF;
		  border: 1;
		  text-align: center;
		}  
		  
		td:hover {
		  background-color: #FF6000;
		  color: #000;
		  border: 1;
		  text-align: center;
		}
	
	]])
	
	self:setBounds(200,200, 500, 400)
	
	self.btTeste = Button("Teste")
	self.btTeste:setBounds(10, 10, 100, 30)   
	
	self:add(self.btTeste)	
	
	self.list = Table()
	self.list:setBounds(Graphics.relativeW(20),Graphics.relativeH(40),self:getHeight() - Graphics.relativeW(40), Graphics.relativeH(100))   
	self.list:setColumns({
	  {name='Serial',w=self.list:getWidth() / 3},
	  {name='Ip',w=self.list:getWidth()/ 3},
	  {name='nick',w=self.list:getWidth()/ 3},
	})
	
	function onTableClick(item)
	
	end
	
	self.list:addRow(1,{"coluna 1","coluna 2","coluna 3"}, "linha1", onTableClick)
	self.list:addRow(2,{"coluna 1","coluna 2","coluna 3"}, "linha2", onTableClick)
	 
	self:add(self.list)	
	
	return self
end

showCursor(true)
Toolkit.getInstance():add(LuaObject.getSingleton(TableTest))