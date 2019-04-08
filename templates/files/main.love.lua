--[[
 @package   
 @filename  {filename}
 @version   {version}
 @autor     {developer} <{mail}>
 @date      {datetime}
]]--

function love.load()
end

function love.update(dt)
end

function love.draw()
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end
