
--[[
local stylesheet = StylesheetParser.new():init():parsestr([ [

body{
    font-family: Century;
    background: rgb(51,51,51);
    color: #fff;
    padding:20px;
}

.pagina{
    width:auto;
    height:auto;
}

.linha{
    width:auto;
    padding:5px;
    height:auto;
    display:table;
}

table,td,th
{
	border:1px solid black;
}
table
{
	width:100%;
}
th
{
	height:50px;
}

table, td, th
{
	border:1px solid green;
}
th
{
	background-color:green;
	color:white;
}

#ipodlist tr.alt td 
{
	color:#000000;
	background-color:#EAF2D3;
}

--] ])

--outputDebugString("Testando...")
for k,v in pairs(stylesheet.style) do
	outputDebugString(k .. " = " .. toJSON(v))
end
]]