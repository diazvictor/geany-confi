--[[!
 @package   GeanyPluginsLua
 @filename  git/add.lua
 @version   1.0
 @autor     Díaz Urbaneja Víctor Eduardo Diex <diaz.victor@openmailbox.org>
 @date      09.07.2018 01:42:56 -04
]]--

-- Variables

local file_path = geany.fileinfo().path

buttons         = {"Acept","Cancel"}
dlg             = dialog.new("Commit", buttons)

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
	os.capture("cd "..file_path..";git add "..result.input)
	geany.status("Add "..file_path..result.input)
	if result.input == "." then
		geany.status("Add all")
	end
end
