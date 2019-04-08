# For complete documentation of this file, please see Geany's main documentation

[styling]
# Edit these in the colorscheme .conf file intead
default=default
comment=comment
commentline=comment_line
commentdoc=comment_line_doc
number=number_1
#word=#72b3cc
string=string_1
character=character
literalstring=string_2
preprocessor=preprocess
operator=operator
identifier=identifier_1
stringeol=string_eol
function_basic=function
function_other=type
coroutines=class
word6=keyword_2
word7=keyword_3
word8=keyword_4
word5=function

[keywords]
# all items must be in one line
keywords=and break do else elseif end false for function if in local nil not or repeat return then true until while
# Basic functions
function_basic=_ALERT assert call collectgarbage coroutine debug dofile dostring error _ERRORMESSAGE foreach foreachi _G gcinfo getfenv getmetatable getn globals _INPUT io ipairs load loadfile loadlib loadstring math module newtype next os _OUTPUT pairs pcall print _PROMPT rawequal rawget rawset require select setfenv setmetatable sort _STDERR _STDIN _STDOUT string table tinsert tonumber tostring tremove type unpack _VERSION xpcall
# String, (table) & math functions
function_other=abs acos asin atan atan2 ceil cos deg exp floor format frexp gsub ldexp log log10 math.abs math.acos math.asin math.atan math.atan2 math.ceil math.cos math.cosh math.deg math.exp math.floor math.fmod math.frexp math.huge math.ldexp math.log math.log10 math.max math.min math.mod math.modf math.pi math.pow math.rad math.random math.randomseed math.sin math.sinh math.sqrt math.tan math.tanh max min mod rad random randomseed sin sqrt strbyte strchar strfind string.byte string.char string.dump string.find string.format string.gfind string.gmatch string.gsub string.len string.lower string.match string.rep string.reverse string.sub string.upper strlen strlower strrep strsub strupper table.concat table.foreach table.foreachi table.getn table.insert table.maxn table.remove table.setn table.sort tan
# (coroutines), I/O & system facilities
coroutines=appendto clock closefile coroutine.create coroutine.resume coroutine.running coroutine.status coroutine.wrap coroutine.yield date difftime execute exit flush getenv io.close io.flush io.input io.lines io.open io.output io.popen io.read io.stderr io.stdin io.stdout io.tmpfile io.type io.write openfile os.clock os.date os.difftime os.execute os.exit os.getenv os.remove os.rename os.setlocale os.time os.tmpname package.cpath package.loaded package.loadlib package.path package.preload package.seeall read readfrom remove rename seek setlocale time tmpfile tmpname write writeto
# user definable keywords
## Put this in the [keywords] section:
user1=geany.activate geany.appinfo geany.banner geany.basename geany.batch geany.byte geany.caller geany.caret geany.choose geany.close geany.confirm geany.copy geany.count geany.cut geany.dirlist geany.dirname geany.dirsep geany.documents geany.fileinfo geany.filename geany.find geany.fullpath geany.height geany.input geany.keycmd geany.keygrab geany.launch geany.length geany.lines geany.match geany.message geany.navigate geany.newfile geany.open geany.optimize geany.paste geany.pickfile geany.pluginver geany.rectsel geany.reloadconf geany.rescan geany.rowcol geany.save geany.scintilla geany.script geany.select geany.selection geany.signal geany.stat geany.status geany.text geany.timeout geany.wkdir geany.word geany.wordchars geany.xsel geany.yield dialog.checkbox dialog.color dialog.file dialog.font dialog.group dialog.heading dialog.hr dialog.label dialog.new dialog.option dialog.password dialog.radio dialog.run dialog.select dialog.text dialog.textarea keyfile.comment keyfile.data keyfile.groups keyfile.has keyfile.keys keyfile.new keyfile.remove keyfile.value Gtk.main Gtk.main_quit
# user2=show_all on_destroy open query close run hide on_clicked add_from_file
# user3=
# user4=

[settings]
# default extension used when saving files
extension=lua

# MIME type
mime_type=text/lua

# the following characters are these which a "word" can contains, see documentation
#wordchars=_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789

# single comments, like # in this file
comment_single=--
# multiline comments
comment_open=--[[--
comment_close=]]

# set to false if a comment character/string should start at column 0 of a line, true uses any
# indentation of the line, e.g. setting to true causes the following on pressing CTRL+d
	#command_example();
# setting to false would generate this
#	command_example();
# This setting works only for single line comments
comment_use_indent=true

# context action command (please see Geany's main documentation for details)
#context_action_cmd=chromium-browser /usr/share/doc/geanylua/geanylua-ref.html#%s
context_action_cmd=zeal "lua:%s"

[indentation]
#width=4
# 0 is spaces, 1 is tabs, 2 is tab & spaces
#type=1

[build_settings]
# %f will be replaced by the complete filename
# %e will be replaced by the filename without extension
# (use only one of it at one time)
compiler=
run_cmd=lua "%f"

[build-menu]
FT_00_LB=_Insppector de codigo
FT_00_CM=luacheck --no-color -guras --no-max-line-length %f
FT_00_WD=
FT_02_LB=
FT_02_CM=
FT_02_WD=
EX_00_LB=_Ejecutar
EX_00_CM=lua "%f"
EX_00_WD=
EX_01_LB=
EX_01_CM=
EX_01_WD=
FT_01_LB=_Generar documentación
FT_01_CM=ldoc -v -d doc -a "%f"
FT_01_WD=
