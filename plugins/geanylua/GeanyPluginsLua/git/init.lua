--[[!
 @package   GeanyPluginsLua
 @filename  git/init.lua
 @version   1.0
 @autor     Díaz Urbaneja Víctor Eduardo Diex <diaz.victor@openmailbox.org>
 @date      05.07.2018 16:51:22 -04
]]--

-- Variables
local file_path = geany.fileinfo().path
local dc        = geany.dirsep

buttons         = {"Acept","Cancel"}
dlg             = dialog.new("Git Init",    buttons)

acept, result   = dlg:run()

function os.capture(cmd, raw)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	if raw then return s end
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', ' ')
	return s
end

if (acept == 1) then
	os.capture("cd "..file_path..";git init")
	geany.status("Initialized empty Git repository in "..file_path..".git"..dc)
end
