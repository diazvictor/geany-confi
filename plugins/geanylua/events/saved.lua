--
--       saved.lua
--
--       Copyright 2012 Eddy Ernesto del Valle Pino <edelvalle@hab.uci.cu>
--
--       This program is free software; you can redistribute it and/or modify
--       it under the terms of the GNU General Public License as published by
--       the Free Software Foundation; either version 2 of the License, or
--       (at your option) any later version.
--
--       This program is distributed in the hope that it will be useful,
--       but WITHOUT ANY WARRANTY; without even the implied warranty of
--       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--       GNU General Public License for more details.
--
--       You should have received a copy of the GNU General Public License
--       along with this program; if not, write to the Free Software
--       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
--       MA 02110-1301, USA.
--
--

extencion = geany.fileinfo().ext

if (extencion == '.py') or (extencion == '.po') or (extencion == '.coffee') or (extencion == ".lua") or (extencion == ".js") or --[[(extencion == ".css") or]] (extencion == ".less") --[[(extencion == ".html")]] or (extencion == ".php") then
	geany.keycmd('BUILD_COMPILE')
end
