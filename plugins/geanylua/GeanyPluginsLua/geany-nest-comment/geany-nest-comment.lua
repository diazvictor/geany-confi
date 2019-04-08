-- @ACCEL@ <Control><Shift>e

--[[
 @package   GeanyPluginsLua
 @filename  geany-nest-comment/nest-comment.lua
 @version   1.0
 @autor     Díaz Urbaneja Víctor Eduardo Diex <diaz.victor@openmailbox.org>
 @date      06.07.2018 15:43:13 -04
]]--

-- -------------------------------------------------------------
-- Variables/Tablas
-- -------------------------------------------------------------

cmt = {}

template = {
	author   = geany.appinfo().template.developer,
	mail     = geany.appinfo().template.mail,
	version  = geany.appinfo().template.version,
	datetime = os.date("%d.%m.%Y %H:%M:%S %Z")
}

local selection = geany.selection()
local extencion = geany.fileinfo().ext

-- -------------------------------------------------------------
-- Funciones
-- -------------------------------------------------------------

function comment()
	if (geany.filename() ~= nil) then
		if (selection ~= "") and (selection ~= nil) then
			local valor     = string.match(selection,':.*'):gsub(":","")
			-- @TODO : luego estare usando esta variable
			local argumento = string.match(selection,'^.*:')

			if extencion == ".lua" then
				if selection == "cmt-simple:"..valor  or selection == "cmt:"..valor then
					cmt.simple = "-- _val_"
					geany.selection(cmt.simple:gsub("_val_", valor))
				elseif selection == "cmt-section:"..valor then
					-- cmt.section = "\n-- -------------------------------------------------------------\n-- _val_\n-- -------------------------------------------------------------\n\n-- End of _val_ --------------------------------\n"
					cmt.section = "-- ===============================================\n-- =                    _val_                    =\n-- ===============================================\n\n-- ===============  End of _val_  ================"
					geany.selection(cmt.section:gsub("_val_", valor))
				elseif selection == "cmt-subsection:"..valor then
					cmt.subsection = "\n-- -------------------------------------------------------------\n-- _val_\n-- -------------------------------------------------------------\n\n-- End of _val_ --------------------------------\n"
					geany.selection(cmt.subsection:gsub("_val_", valor))
				elseif selection == "cmt-section-header:"..valor then
					cmt.header = "-- ===============================================\n-- =                    _val_                    =\n-- ===============================================\n"
					geany.selection(cmt.header:gsub("_val_", valor))
				elseif selection == "cmt-subsection-header:"..valor then
					cmt.header = "-- -------------------------------------------------------------\n-- _val_\n-- -------------------------------------------------------------"
					geany.selection(cmt.header:gsub("_val_", valor))
				elseif selection == "cmt-section-footer:"..valor then
					cmt.footer = "-- ===============  End of _val_  ================"
					geany.selection(cmt.footer:gsub("_val_", valor))
				elseif selection == "cmt-subsection-footer:"..valor then
					cmt.footer = "-- End of _val_ --------------------------------"
					geany.selection(cmt.footer:gsub("_val_", valor))
				elseif selection == "cmt-todo:"..valor then
					cmt.todo = "-- @TODO : _val_"
					geany.selection(cmt.todo:gsub("_val_", valor))
				elseif selection == "cmt-head:"..valor then
					filename = geany.basename(geany.filename())
					cmt.head = "--[[\n @package   _val_\n @filename  "..filename.."\n @version   "..template.version.."\n @author    "..template.author.." <"..template.mail..">".."\n @date      "..template.datetime.."\n]]--"
					geany.selection(cmt.head:gsub("_val_", valor))
				--else
					---geany.status("snippet false")
				end
			end

			if extencion == ".css" or extencion == ".js" or extencion == ".c" or extencion == ".cpp" or extencion == ".h" then
				if selection == "cmt-simple:"..valor then
					cmt.simple = "/** _val_ **/"
					geany.selection(cmt.simple:gsub("_val_", valor))
				elseif selection == "cmt-long:"..valor then
					cmt.long = "/**\n * _val_\n */"
					geany.selection(cmt.long:gsub("_val_", valor))
				elseif selection == "cmt-section:"..valor then
					cmt.section = "/*==============================================\n=                  _val_                  =\n==============================================*/\n\n/*============ End of _val_ =============*/"
					geany.selection(cmt.section:gsub("_val_", valor))
				elseif selection == "cmt-head:"..valor then
					filename = geany.basename(geany.filename())
					cmt.head = "/**!\n * @package   _val_\n * @filename  "..filename.."\n * @version   "..template.version.."\n * @author    "..template.author.."\n * @date      "..template.datetime.."\n */\n"
					geany.selection(cmt.head:gsub("_val_", valor))
				--else
					--geany.status("snippet false")
				end
			end

			if extencion == ".html" then
				if selection == "cmt-simple:"..valor  then
					cmt.simple = "<!-- _val_ -->"
					geany.selection(cmt.simple:gsub("_val_", valor))
				elseif selection == "cmt:"..valor then
					cmt.simple = "<!-- _val_ -->"
					geany.selection(cmt.simple:gsub("_val_", valor))
				elseif selection == "cmt-block:"..valor then
					cmt.multiline = geany.fileinfo().opener.."\n\n\t_val_\n\n"..geany.fileinfo().closer
					geany.selection(cmt.multiline:gsub("_val_", valor))
				elseif selection == "cmt-section:"..valor then
					cmt.section = "<!--==============================================\n=                  _val_                  =\n==============================================-->\n\n<!--============ End of _val_ ============-->"
					geany.selection(cmt.section:gsub("_val_", valor))
				--else
					--geany.status("snippet false")
				end
			end
		--else
			-- return geany.keycmd("EDITOR_COMPLETESNIPPET")
			--geany.status("snippet false")
		end
	--else
		--geany.message("la ruta es nula")
	end
end

comment()
