--[[
 @package   Envents
 @filename  init.lua
 @version   1.0
 @author    Díaz Urbaneja Víctor Eduardo Diex <diaz.victor@openmailbox.org>
 @date      14.07.2018 05:05:37 -04
]]--

local myconfig = [[

					  ____
					 / ___| ___  __ _ _ __  _   _
					| |  _ / _ \/ _` | '_ \| | | |
					| |_| |  __/ (_| | | | | |_| |
					 \____|\___|\__,_|_| |_|\__, |
											|___/

				Mostrar todos los Comandos Ctrl+Shift+p
							 Ir al archivo Ctrl+p
						Buscar en archivos Ctrl+Shift+f
						Iniciar depuracion F8
						  Ir a la terminal F3
]]

--local linux_content = [[
						  --____
						 --/ ___| ___  __ _ _ __  _   _
						--| |  _ / _ \/ _` | '_ \| | | |
						--| |_| |  __/ (_| | | | | |_| |
						 --\____|\___|\__,_|_| |_|\__, |
												--|___/
--
					--Mostrar todos los Comandos Ctrl+Shift+p
								 --Ir al archivo Ctrl+p
							--Buscar en archivos Ctrl+Shift+f
							--Iniciar depuracion F8
							  --Ir a la terminal F3
--]]

local content_window = [[

						  ____
						 / ___| ___  __ _ _ __  _   _
						| |  _ / _ \/ _` | '_ \| | | |
						| |_| |  __/ (_| | | | | |_| |
						 \____|\___|\__,_|_| |_|\__, |
												|___/

					Mostrar todos los Comandos Ctrl+Mayús+p
								 Ir al archivo Ctrl+p
							Buscar en archivos Ctrl+Mayús+f
							Iniciar depuracion F8
							  Ir a la terminal F3
]]

dirsep = geany.dirsep
file = "/tmp/Pagina\ de\ Inicio"

-- Detecta si el file existe
local function file_exist(file)
	-- return (io.open(file, "r") == nil) and false or true
	local file_found = io.open(file, "r")
	if (file_found == nil) then
		return false
	end
	return true
end

if (dirsep == "/") then
--if (geany.appinfo().project == nil) then
	if (file_exist(file) == false) then
		geany.newfile(file)
		geany.open(file)
		geany.text(myconfig)
		geany.save()
		geany.scintilla("SetCursor",2)
		geany.scintilla("SetZoom",4)
		geany.scintilla("HideSelection",true)
		geany.scintilla("SetIndentationGuides",0)
	else
		geany.newfile(file)
		geany.open(file)
		geany.text(myconfig)
		geany.save()
		geany.scintilla("SetZoom",4)
		geany.scintilla("HideSelection",true)
		geany.scintilla("SetIndentationGuides",0)
	end
elseif (dirsep == "\\") then
	geany.newfile(file)
	geany.open(file)
	geany.text(content_window)
	geany.save()
	geany.scintilla("SetZoom",4)
	geany.scintilla("HideSelection",true)
	geany.scintilla("SetIndentationGuides",0)
end
