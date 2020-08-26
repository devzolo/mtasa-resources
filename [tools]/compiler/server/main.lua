g_compiledResource = {}

function loadFile(file)
	local hFile = fileOpen(file, true)

	if hFile then
		local buffer
		while not fileIsEOF(hFile) do
    		buffer = fileRead(hFile, 100000000)	
		end
		fileClose(hFile)
		return buffer
	else
		outputDebugString("Erro ao ler o arquivo: "..file)
	end
end

function saveFile(fileName, buffer)
	local newFile = fileCreate(fileName)
	if (newFile) then
	    fileWrite(newFile, buffer)
	    fileClose(newFile)
	end
end

function compileScript(script)
	local options = script.options

	local optionStr = ""
	optionStr = optionStr .. "compile=" .. (options.compile and "1" or "0") .. "&"
	optionStr = optionStr .. "obfuscate=" .. (options.encrypt and "2" or "0") .. "&"
	optionStr = optionStr .. "debug=" .. (options.debug and "1" or "0")
	
	--outputDebugString("Compilando " .. getResourceName(script.resource))
	
	if(type(script.codeFile) == "string") then
		fetchRemote( "http://luac.mtasa.com/index.php?" .. optionStr, recieveEncrypt, loadFile(script.codeFile), true, script)
	elseif(type(script.codeFile) == "table") then
		local buffer = ""
		local deleteBuffer = ""
		for k,v in pairs(script.codeFile) do
			local codeFile = v
			if(type(v) == "table") then
				codeFile = v.codeFilePath
				if(v.deleteMe and v.codePath) then
					deleteBuffer = deleteBuffer .. string.format("if(fileExists('%s')) then fileDelete('%s') end", v.codePath, v.codePath) .. "\r\n"
				end
			end
			buffer = buffer .. loadFile(codeFile) .. "\r\n"
		end
		buffer = buffer .. deleteBuffer
		buffer = utf8.insert("", buffer)
		local checksum = md5(buffer .. optionStr)
		if(options.checksum ~= checksum) then
			script.compiled = false
			outputDebugString("Compilando " .. getResourceName(script.resource) .. " = " .. script.srcFile)
			xmlNodeSetAttribute(script.node, "checksum", checksum)
			if(not options.compile and not options.encrypt) then
				recieveEncrypt(buffer, 0, script)
			else
				fetchRemote( "http://luac.mtasa.com/index.php?" .. optionStr, recieveEncrypt, buffer, true, script)
			end
			return true
		else
			script.compiled = true
		end
	end
	return false
end

function recieveEncrypt(buffer, errno, script)
	if (errno == 0) then
		saveFile(script.srcFile, buffer)
		script.compiled = true
		
		local scripts = g_compiledResource[script.resource]
		if(scripts) then
			local restart = false
			for _,v in pairs(scripts) do
				if(not v.compiled) then
					restart = true
					--outputDebugString("script " .. "alterado")	
					--break
				end
			end
			if(restart) then
				outputDebugString("reiniciando resource " .. getResourceName(script.resource))
				restartResource(script.resource)
				outputDebugString("resource reiniciado " .. getResourceName(script.resource))
				g_compiledResource[script.resource] = nil		
			else
				outputDebugString("not reiniciando resource " .. getResourceName(script.resource))	
			end
		end
	else
		outputChatBox("Aconteceu algum erro ao compilar: " .. errno.. " o arquivo: ".. file)
	end
end

function getBooleanFromValue(value)
	if(value == "1" or value == "true" or value == true) then
		return true
	end
	return false
end

function getCompileOptions(scriptNode)
	return {
		composer = getBooleanFromValue(xmlNodeGetAttribute(scriptNode, "composer")),
		compile  = getBooleanFromValue(xmlNodeGetAttribute(scriptNode, "compile")),
		debug  = getBooleanFromValue(xmlNodeGetAttribute(scriptNode, "debug")),
		blockdecompile  = getBooleanFromValue(xmlNodeGetAttribute(scriptNode, "blockdecompile")),
		encrypt  = getBooleanFromValue(xmlNodeGetAttribute(scriptNode, "encrypt")),
		checksum  = xmlNodeGetAttribute(scriptNode, "checksum")
	}
end

function getCodePath(resourceName, path)
	return string.sub(path,1,1) == ':' and path or ':' .. resourceName .. '/' .. path
end

function isLocalCodePath(path)
	return string.sub(path,1,1) ~= ':'
end

function loadMetaFile(res)
	local resourceName = getResourceName(res)
	local meta = xmlLoadFile(':' .. resourceName .. '/' .. 'meta.xml')
	if not meta then
		outputDebugString('Error while loading ' .. resourceName .. ': no meta.xml', 2)
		return false
	end
	local scriptTable = {}
	local scriptNode = xmlFindChild(meta, 'script', 0)
	local i = 1
	while scriptNode do
		local isClient = string.lower(xmlNodeGetAttribute(scriptNode, "type") or "") == "client"
		local isComposer = xmlNodeGetAttribute(scriptNode, "composer")
		if(isComposer) then		
			local codeFileTable = {}
			local codeFileDeleteTable = {}
			--
			local codeNode = xmlFindChild(scriptNode, 'code', 0)
			if(codeNode) then
				local j = 1
				while codeNode do
					local codePath = xmlNodeGetAttribute(codeNode, "src")
					local codeFile = getCodePath(resourceName, codePath)
					table.insert(codeFileTable, codeFile)
					codeNode = xmlFindChild(scriptNode, "code", j)
					j = j + 1		
				end
			end
			---
			codeNode = xmlFindChild(scriptNode, 'script', 0)
			if(codeNode) then
				local j = 1
				while codeNode do
					local codePath = xmlNodeGetAttribute(codeNode, "src")
					local codeFilePath = getCodePath(resourceName, codePath)
					table.insert(codeFileTable, {codeFilePath = codeFilePath, codePath = codePath, deleteMe = isClient and isLocalCodePath(codePath)})
					codeNode = xmlFindChild(scriptNode, "script", j)
					j = j + 1		
				end
			end			
			--
			local srcPath = xmlNodeGetAttribute(scriptNode, "src")
			
			 
			if(srcPath) then				
				local options = getCompileOptions(scriptNode)
				local srcFile = ':' .. resourceName .. '/' .. srcPath
				table.insert(scriptTable, {codeFile = codeFileTable, srcFile = srcFile, options = options, node = scriptNode, resource = res})
			end	
			
			if(#codeFileDeleteTable > 0) then				
				for k,v in pairs(codeFileDeleteTable) do
					
				end
				table.insert(scriptTable, {codeFile = codeFileTable, srcFile = srcFile, options = options, node = scriptNode, resource = res})
			end	
				
		else
			local codePath = xmlNodeGetAttribute(scriptNode, "code")
			if(codePath) then
				local options = getCompileOptions(scriptNode)
				local srcPath = xmlNodeGetAttribute(scriptNode, "src")
				local codeFile = getCodePath(resourceName, codePath)
				local srcFile = ':' .. resourceName .. '/' .. srcPath
				table.insert(scriptTable, {codeFile = codeFile, srcFile = srcFile, options = options, node = scriptNode, resource = res})
			end
		end
		scriptNode = xmlFindChild(meta, "script", i)
		i = i + 1
	end	
	
	local restart = false
	for k,script in pairs(scriptTable) do
		if(compileScript(script) and not restart) then
			g_compiledResource[res] = scriptTable
			restart = true
		end
	end
	
	if(#scriptTable == 0) then
		xmlUnloadFile(meta)
	else
		xmlSaveFile(meta)
	end
end

function onResourcePreStart(res)
	loadMetaFile(res)
end
addEventHandler("onResourcePreStart", root, onResourcePreStart)

function compileCommandHandler(player, cmd, resourceName)
	if(hasObjectPermissionTo(player, "command.ban", false)) then
		if(resourceName) then
			local res = getResourceFromName(resourceName)
			if(res) then
				loadMetaFile(res)
			end
		end
	end
end
addCommandHandler("compile", compileCommandHandler)