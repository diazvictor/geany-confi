--[[--
 @module    GeanyPluginsLua
 @filename  utils.lua
 @version   1.0
 @author    Díaz Urbaneja Víctor Eduardo Diex <diaz.victor@openmailbox.org>
 @date      10.07.2018 21:28:37 -04
--]]

-- ===================================================
-- =                    Variables                    =
-- ===================================================

_HOME = geany.wkdir()
_SCRIPDIR = geany.appinfo().scripdir
_DS = geany.dirsep

utils = {
	fileinfo = {
		filefull = geany.filename(), -- Returns the full path and filename of the current Geany document. If there is no open document, or if the current document is untitled, returns nil.
		filepath = geany.fileinfo().path, -- The full path of the file's directory, including the trailing slash.
		filename = geany.basename(geany.filename()),
		extencion = geany.fileinfo().ext
	},
	template = {
		author = geany.appinfo().template.developer,
		mail = geany.appinfo().template.mail,
		version = geany.appinfo().template.version,
		datetime = os.date("%d.%m.%Y %H:%M:%S %Z")
	}
}

-- ===================================================
-- =                    Funciones                    =
-- ===================================================



-- @usage if (OS == "Unix") then geany.message("Este sistema es unix") end
local OS = nil

if (_DS == "/") then
	OS = 'Unix'
elseif (_DS == "\\") then
	OS = 'Windows'
end

-- Funcion que crea un archivo mediante lo que seleccionemos
function utils.newfile_selection()
	local selection = geany.selection()
	if (selection ~= "") and (selection ~= nil) then
		local t = geany.fileinfo()
		geany.newfile("", t.type)
		geany.selection(selection)
	end
end

-- Funcion que detecta si un archivo existe
function utils.file_exist(file)
	-- return (io.open(file, "r") == nil) and false or true
	local file_found = io.open(file, "r")
	if (file_found == nil) then
		return false
	end
	return true
end

-- Funcion que escribe en un archivo
function utils.write(file , text)
	-- Abro el archivo.
	geany.open(file)
	-- Escribo en el archivo.
	geany.text(text)
	-- Guardo el archivo.
	geany.save()
	-- Cierro el archivo.
	geany.close()
	-- Muestro un mensaje si se ha escrito en el archivo
	geany.message("Has escrito: "..string.." en "..file)
	-- De esta manera lo hago con funciones internas de lua
	-- Abro el archivo.
	-- file = io.open(file,"a")
	-- Escribo en el archivo.
	-- file:write(text)
	-- Cierro el archivo.
	-- file:close()
	-- print("Has escrito: "..string.." en "..file)
end

-- Funcion para crear un archivo.
function utils.create_file(file, text, message1, message2)
	-- Si el archivo no existe lo creo.
	if (utils.file_exist(file) == false) then
		-- Creo el archivo.
		geany.newfile(file)
		-- Abro el archivo.
		geany.open(file)
		-- Escribo en el archivo.
		geany.text(text)
		-- Guardo el archivo.
		geany.save()
		-- Cierro el archivo.
		geany.close()
		-- Mensaje si se ha creado el archivo.
		geany.message(message1)
	else
		-- Mensaje si no se ha creado el archivo.
		geany.message(message2)
	end
end

-- Funcion que diferencia si el archivo no esta creado (nil)
-- @usage utils.diff_file("El archivo es nulo")
-- function utils.diff_file(message)
	-- local filename = geany.filename()
	-- if (filename ~= nil) then
		-- geany.message(filename)
	-- else
		-- geany.message(message)
	-- end
-- end

-- Funcion que crea un direcctorio mediante un input
function utils.create_dir(input, file_path)
	if (input) then
		local input = file_path..input
		dir         = input:match("^.*/") -- busco solo lo que esta detras de los slash
		if (OS == 'Unix') then
			geany.launch("mkdir", "-p", dir)
		elseif (OS == 'Windows') then
			dir = dir:gsub('/','\\')
			geany.launch("mkdir", dir)
		end
	end
end
