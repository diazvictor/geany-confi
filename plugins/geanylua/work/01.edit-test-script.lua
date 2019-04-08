--[[
Opens the existing script named "run-test-script.lua" that you can use
for development. If the script does not exist it will be created and
added to the "Tools->Lua Scripts" menu, under the same menu item as
this one.
--]]

local template = {
	author   = geany.appinfo().template.developer,
	mail     = geany.appinfo().template.mail,
	version  = geany.appinfo().template.version,
	datetime = os.date("%d.%m.%Y %H:%M:%S %Z")
}

local test_script=geany.dirname(geany.script)..geany.dirsep.."02.run-test-script.lua"


local comment=' @package   GeanyPluginsLua\n @filename  02.run-test-script.lua\n @version   '..template.version..'\n @author    '..template.author..' <'..template.mail..'>'..'\n @date      '..template.datetime

repeat
	local stat,err=geany.stat(test_script)
	if stat then
		if stat.type=="r" then
			if geany.open(test_script) == 0 then
				geany.message("Can't open script!", test_script.."\nAccess denied.")
			end
		else
			geany.message("Can't open script!", test_script.."\nNot a regular file.")
		end
		break
	else
		if geany.confirm("Can't open script!", test_script..
		"\n"..err.."\n\nWould you like to create this file?", true)
		then
			fh,err=io.open(test_script,"w")
			if fh then
				fh:write("--[[--\n"..comment.."\n--]]\n\n")
				if fh:close() then
					geany.rescan()
				else
					geany.message("Can't create script!", "Error saving file.")
					break
				end
			else
				geany.message("Can't create script!", err)
				break
			end
		else
			break
		end
	end
until false
