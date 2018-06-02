# Railscasts' TextMate theme.

[styling]
default=default
comment=comment
commentline=comment_line
commentdoc=comment_line_doc
number=number_1
word=keyword_1
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
word5=keyword_1
word6=keyword_2
word7=keyword_3
word8=keyword_4

[keywords]
# all items must be in one line
primary=__FILE__ load define_method attr_accessor attr_writer attr_reader and def end in or self unless __LINE__ begin defined? ensure module redo super until BEGIN break do false next rescue then when END case else for nil include require retry true while alias class elsif if not return undef yield raise


[settings]
# the following characters are these which a "word" can contains, see documentation
#wordchars=_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789

# if only single comment char is supported like # in this file, leave comment_close blank
comment_open=#
comment_close=

# set to false if a comment character/string should start at column 0 of a line, true uses any
# indentation of the line, e.g. setting to true causes the following on pressing CTRL+d
	#command_example();
# setting to false would generate this
#	command_example();
# This setting works only for single line comments
comment_use_indent=true

# context action command (please see Geany's main documentation for details)
context_action_cmd=

[build_settings]
# %f will be replaced by the complete filename
# %e will be replaced by the filename without extension
# (use only one of it at one time)
compiler=ruby1.8 -c "%f"
run_cmd=ruby1.8 "%f"
