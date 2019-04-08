--[[!
 @package   GeanyPluginsLua
 @filename  git/remote.lua
 @version   1.0
 @autor     Díaz Urbaneja Víctor Eduardo Diex <diaz.victor@openmailbox.org>
 @date      09.07.2018 13:39:10 -04
]]--

local file_path = geany.fileinfo().path

buttons         = {"Acept","Cancel"}
dlg             = dialog.new("Git Commit", buttons)

dlg:text("input", nil, "")

acept, result = dlg:run()

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
	os.capture("cd "..file_path..";git remote add "..result.input)
end
