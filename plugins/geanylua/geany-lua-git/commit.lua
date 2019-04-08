--[[
	Requirements
		- git
		- geany-plugins geanyLua
	
	Place this script in:  /usr/share/geany-plugins/geanylua/edit
	Run from geany IDE by choosing Tools->LuaScripts->Edit->Commit
	
]]


local FILE_PATH = geany.filename() -- geany.filename() cijeli path, ne samo ime!
local FILE_DIR_PATH = geany.dirname(geany.filename())
local FILE_NAME = geany.basename(geany.filename())


--izvrsava komandu
function runCommand(cmd)
	
	handle = io.popen(cmd)
	result = handle:read("*a")
	handle:close()
	geany.message(" "..cmd.." :\n"..result.."")
	
	return result
end
	
--provjerava je li neki program instliran
function isInstaled(program)

	local cmd = ""..program.." --version 2>&1"
	result=runCommand(cmd)
	
		if string.match(result,"not found") then
			install_msg="Before you start using "..program..", you have to make it available on your computer. You can either install it as a package or via another installer, or download the source code and compile it yourself. \nDebian/Ubuntu:\n$ apt-get install "..program.." \nFedora:\n $ yum install "..program..""
			geany.message(install_msg)
			return nil
		
		else return 1
		
		end
		
end

-- Lua implementation of PHP scandir function
function scandir(directory)

    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls "'..directory..'"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

-- spoji vrijednosti u tablici u dugacak string s \t između
function listvalues(s)
    local t = { }
    for k,v in ipairs(s) do
        t[#t+1] = tostring(v)
    end
    return table.concat(t,'\t')
end

-- ispisuje checkboxove svih fileova u folderu čiji path primi, radi git add na odabranima. Vraca tablicu odabranih
function addFiles(path)

	local files = scandir(path)
	local yes_no = {"Add","Cancel"}
	local dialog= dialog.new ("Add files", yes_no)
	dialog.label(dialog, "Pick files to add")
		
	for i,file in ipairs(files) do
			dialog:checkbox(files[i], false,files[i])	
		end

	local button, results = dialog:run()
	local checked={}
	local i = 1

	if results then

		for key,value in pairs(results) do
			if value == "1" then
				checked[i]=key
				i=i+1
				cmd ="cd "..path.."  2>&1\ngit add "..key.."  2>&1"
				result=runCommand(cmd)
			end
		end
		return checked
	end	
	
end

-- nakon inicijalizacije dodaje ime pod kojim se izvršava svako commitanje (zapise u config tog repozitorija
function logIn()

	local yes_no = {"OK","Cancel"}
	local dialogUser = dialog.new ("		Log In				", yes_no)
	local dialogEmail = dialog.new("		Log In				", yes_no)
	dialog.text(dialogUser, "username", "", "Username" )
	dialog.text(dialogEmail, "email", "", "Email   " )

	local btU, resU = dialog.run(dialogUser)
		for key,value in pairs(resU) do			
			name=value
		end

	local btnE, resE = dialog.run(dialogEmail)
	
	if resE then
		for key,value in pairs(resE) do	
			email=value
		end
	end

	cmd="cd "..FILE_DIR_PATH.."\ngit config user.name "..name.."\ngit config user.email "..email
	
	result=runCommand(cmd)

end

-- push-a commitane promjene na udaljeni repozitorij, traži password i username tog repozitorija
function pushToOrigin(warning)
	
	local yes_no = {"OK","Cancel"}
	local dialogUser= dialog.new ("		Username		", yes_no)
	local dialogPass= dialog.new ("		Password		", yes_no)
	dialog.label(dialogUser, warning)
	dialog.text(dialogUser, "username", "", "Username" )
	dialog.password (dialogPass, "password", "", "Password" )
	
	local btnU, resU = dialog.run(dialogUser)
	
	
	if (btnU ~= 1) then return end
	
	if resU then
		for key,value in pairs(resU) do	
			name=value
		end
	end
	
	local btnP, resP = dialog.run(dialogPass)

	if (btnP ~= 1) then return end
	
	if resP then
		for key,value in pairs(resP) do
			psw=value
		end
	end
	
	cmd = "cd "..FILE_DIR_PATH.."\ngit config --get remote.origin.url\n"
	origin = runCommand(cmd)
	resultOdrezani = string.sub(origin, 9) --pocni od 9.og !
	
	cmd="cd "..FILE_DIR_PATH.." 2>&1\ngit push -u --repo https://"..name..":"..psw.."@"..resultOdrezani.." 2>&1"
	result = runCommand(cmd)
	
	--cmd2="cd "..FILE_DIR_PATH.." 2>&1\ngit push -u origin master2>&1"
	--result2 = runCommand(cmd2)	
	
		if (string.match(result,"set up to track") --[[or string.match(result2,"set up to track")]]) then
			geany.message("Your changes are now saved in remote repositorie!")	
			os.execute(string.format('xdg-open "%s"', origin))
							
		else
			result = pushToOrigin("\nOoops. Wrong Password or Username.\n(Use credentials you use to login\non your repository website)\n")
		end

		
	
	return result
end


function pullFromOrigin()

	geany.banner = "Pull your changes"	
	result = runCommand("cd "..FILE_DIR_PATH.."  2>&1\ngit pull -u origin master 2>&1\n")
	result = runCommand("cd "..FILE_DIR_PATH.."  2>&1\ngit pull -u origin 2>&1\n")
	

end

	geany.banner = "Geany Git assistant"
	
	instaled = isInstaled("git")
	if instaled == nil then return end

	local result = runCommand("cd "..FILE_DIR_PATH.."  2>&1\ngit add "..FILE_PATH.."  2>&1"	)
	
	--if result=="fatal: Not a git repository (or any of the parent directories): .git\n" then --!! obavezno \n, u suprotnom ne radi
	if  string.match(result,"Not a git repository") then	
		geany.banner = "Not a git repository"
		
		local choice = geany.confirm ( "Your file could not be commited", "This directory is not a git repository (or any of the parent directories. Init new repository?", true )

		if choice == true then
			
			--git init
			geany.banner = "Init new repository"
			cmd = "git init "..FILE_DIR_PATH.."  2>&1"	--!! pokazuje ili output ili error
			result = runCommand(cmd)
			
			--git config user.name git config user.email
			logIn()

			--git add
			cmd = "cd "..FILE_DIR_PATH.."  2>&1\ngit add "..FILE_PATH.."  2>&1"
			result = runCommand(cmd)

			result=''

			geany.banner = "Add remote origin"
			choice = geany.confirm ( "Add remote origin", "This directory is only local. Link to web repository? (add origin)", true )
				
				if choice == true then
					
					origin = geany.input("Please use public repository.", "https://")
					cmd = "cd "..FILE_DIR_PATH.."  2>&1\ngit remote add origin "..origin.." "
					result = runCommand(cmd)
					if result=='' then
						geany.message("Hurray!", "Repositories are now linked. Each time you push your code it will be saved on your remote origin. ")
						os.execute(string.format('xdg-open "%s"', origin))
						pullFromOrigin()
					end
					
				end
		end

	end

if result==''  then
	
	geany.banner = "Commit your changes"
	message = geany.input("Write a short message that will be saved as comment to your commit", "no comment")
	
		if message ~= nil then
			result=runCommand("cd "..FILE_DIR_PATH.."  2>&1\n git commit -m \""..message.."\"")
		end
			
	if string.match(result,"Changes not staged for commit") or string.match(result,"untracked files present") then
	
		geany.banner = "Untracked files present or changes not staged for commit"
		choice = geany.confirm("		Add untracked or modified files to repository		"  ,"	Add untracked files to your repository?",true)

		if choice == true then
			
			local list = listvalues( addFiles(FILE_DIR_PATH) )
			
				if(list ~='') then
					geany.banner = "Commit your changes"
					message=geany.input("Commit message", "Added files: "..list)

					if message ~= nil then
						runCommand("cd "..FILE_DIR_PATH.."  2>&1\n git commit -m \""..message.."\"")
					end
				end
		end

	end

	geany.banner = "Pull your changes"	
	local choice = geany.confirm ( "Sometimes push requires pull", "Do you want to pull from origin?", true )

	if choice then 
		pullFromOrigin()
	end
	
	geany.banner = "Push your changes"	
	local choice = geany.confirm ( "Push changes to remote origin", "Do you want to push changes to remote origin?", true )



	if choice then 
	result = pushToOrigin(" ")
		--geany.message("Your changes are now saved in remote repositorie!")
	end
	
end
--[[


	references:
	
	https://plugins.geany.org/geanylua/geanylua-ref.html
	http://plugins.geany.org/geanylua/geanylua-input.html
	http://lua-users.org/
	
	cmds:
	-- 2>&1 pokazuje ili output ili error
	-- ako ulancavamo 2 komande, između stavljamo \n ili |
	-- prije git comande, cd komanda u direktorij datoteke
	
	--"git add remote origin "
	--"git commit -m "
	--"git config user.name ",--"Your Name Here"
	--"git config user.email ",--"your@email.com"

	-- Remove email address from global config:

	--$ git config --global --unset-all user.email
	--$ git config --global --unset-all user.name
]]
