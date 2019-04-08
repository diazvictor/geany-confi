--[[!
 @package   GeanyPluginsLua
 @filename  git/push.lua
 @version   1.0
 @autor     Díaz Urbaneja Víctor Eduardo Diex <diaz.victor@openmailbox.org>
 @date      09.07.2018 13:41:44 -04
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
	geany.message(os.capture("cd "..file_path..";git push -u "..result.input))
end
