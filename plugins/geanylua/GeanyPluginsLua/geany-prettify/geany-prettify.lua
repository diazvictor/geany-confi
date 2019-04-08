--[[!
 @package   GeanyPluginsLua
 @filename  geany-prettify/geany-prettify.lua
 @version   1.0
 @autor     Díaz Urbaneja Víctor Eduardo Diex <diaz.victor@openmailbox.org>
 @date      04.07.2018 07:05:07 -04
]]--

extencion    = geany.fileinfo().ext

if (extencion == ".html") then
	geany.keycmd("FORMAT_SENDTOCMD1")
elseif (extencion == ".css") or (extencion == ".less") then
	geany.keycmd("FORMAT_SENDTOCMD2")
elseif (extencion == ".js") then
	geany.keycmd("FORMAT_SENDTOCMD3")
elseif (extencion == ".lua") then
	geany.keycmd("FORMAT_SENDTOCMD5")
end
