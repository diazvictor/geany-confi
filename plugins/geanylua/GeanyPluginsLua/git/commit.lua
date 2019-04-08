--[[!
 @package   GeanyPluginsLua
 @filename  git/commit.lua
 @version   1.0
 @autor     Díaz Urbaneja Víctor Eduardo Diex <diaz.victor@openmailbox.org>
 @date      04.07.2018 18:42:26 -04
]]--

-- Variables

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
	s = string.gsub(s, '[\n\r]+', '\n\n')
	return s
end

if (acept == 1) then
	geany.message(os.capture("cd "..file_path..";git commit -m ".."'"..result.input.."'").."\n")
end

