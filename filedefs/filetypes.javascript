# For complete documentation of this file, please see Geany's main documentation
[styling]
# foreground;background;bold;italic
default=default
comment=comment
commentline=comment
commentdoc=comment
number=number
commentlinedoc=comment
commentdockeyword=comment
commentdockeyworderror=comment_doc,bold

[keywords]
# all items must be in one line
primary=break case catch class const continue debugger default delete do else enum export extends false finally for function get if import in Infinity instanceof let NaN new null return set static super switch this throw true try typeof undefined var void while with yield prototype async await document console require window ajax post
#secondary=Array Boolean Date Function Math Number Object String RegExp EvalError Error RangeError ReferenceError SyntaxError TypeError URIError constructor prototype decodeURI decodeURIComponent encodeURI encodeURIComponent eval isFinite isNaN parseFloat parseInt $ click ready animate toggle html css ajax add addClass alert write log end listen createServer readlink readFileSync
#success done
secondary=Array Boolean Date Function Math Number Object String RegExp EvalError Error RangeError ReferenceError SyntaxError TypeError URIError constructor prototype decodeURI decodeURIComponent encodeURI encodeURIComponent eval isFinite isNaN parseFloat parseInt alert write log getElementById innerHTML pop push join sort reverse error attr css html fadeIn fadeOut getElementsByClassName getElementsByName getElementsByTagName getElementsByTagNameNS click setInterval $ ready val setTimeout location addClass removeClass toggleClass
#secondary=Array Boolean Date Function Math Number Object String RegExp EvalError Error RangeError ReferenceError SyntaxError TypeError URIError constructor prototype decodeURI decodeURIComponent encodeURI encodeURIComponent eval isFinite isNaN parseFloat parseInt $ click ready animate toggle html css ajax add addBack attr addClass addContext addListener addMembership addTrailers address asin assert basename console log util write document
docComment=a addindex addtogroup anchor arg attention author authors b brief bug c callergraph callgraph category cite class code cond copybrief copydetails copydoc copyright date def defgroup deprecated details dir dontinclude dot dotfile e else elseif em endcode endcond enddot endhtmlonly endif endinternal endlatexonly endlink endmanonly endmsc endrtfonly endverbatim endxmlonly enum example exception extends file fn headerfile hideinitializer htmlinclude htmlonly if ifnot image implements include includelineno ingroup interface internal invariant latexonly li line link mainpage manonly memberof msc mscfile n name namespace nosubgrouping note overload p package page par paragraph param post pre private privatesection property protected protectedsection protocol public publicsection ref related relatedalso relates relatesalso remark remarks result return returns retval rtfonly sa section see short showinitializer since skip skipline snippet struct subpage subsection subsubsection tableofcontents test throw throws todo TODO tparam typedef union until var verbatim verbinclude version warning weakgroup xmlonly xrefitem

[lexer_properties=C]
# partially handles ES6 template strings
lexer.cpp.backquoted.strings=1

[settings]
# default extension used when saving files
extension=js

# MIME type
mime_type=application/javascript

# the following characters are these which a "word" can contains, see documentation
#wordchars=_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789

# single comments, like # in this file
comment_single=//
# multiline comments
comment_open=/*
comment_close=*/

# set to false if a comment character/string should start at column 0 of a line, true uses any
# indentation of the line, e.g. setting to true causes the following on pressing CTRL+d
	#command_example();
# setting to false would generate this
#	command_example();
# This setting works only for single line comments
comment_use_indent=true

# context action command (please see Geany's main documentation for details)
context_action_cmd=zeal jQuery,jqueryui:%s

symbol_list_sort_mode=1

[indentation]
#width=4
# 0 is spaces, 1 is tabs, 2 is tab & spaces
#type=1

[build-menu]
FT_00_LB=_Inspector de codigo
FT_00_CM=jshint "%f"
FT_00_WD=%d
FT_01_LB=
FT_01_CM=
FT_01_WD=
FT_02_LB=
FT_02_CM=
FT_02_WD=
error_regex=([^:]+): line ([0-9]+), col ([0-9]+)
EX_00_LB=_Ejecutar
EX_00_CM=node %f
EX_00_WD=
EX_01_LB=
EX_01_CM=
EX_01_WD=
