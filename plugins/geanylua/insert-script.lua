--[[
 @package   GeanyPluginsLua
 @filename  insert-script.lua
 @version   1.0
 @author    Díaz Urbaneja Víctor Eduardo Diex <diaz.victor@openmailbox.org>
 @date      15.07.2018 13:32:03 -04
]]--

dlg = dialog.new("Script Title",{"OK","Cancel"})
dlg:label(" Enter title for this script")
dlg:text("input",nil,"")
dlg:hr()
acept, result = dlg:run()

if (acept == 1) then
	valor = result.input
	newfile = geany.fileinfo().path..geany.dirsep..valor..".lua"
	geany.newfile(newfile:gsub(" ","-"))
	geany.rescan()
	geany.open(newfile:gsub(" ","-"))
	geany.save()
end
