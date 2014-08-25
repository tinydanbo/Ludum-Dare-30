Gamestate = require "lib.hump.gamestate"
game = require "game.states.game" ---a hah ah ah ah aha

local title = {}

function title:enter(oldState)
	self.titleScreen = love.graphics.newImage("data/graphics/screen_title.png")
	self.titleScreen:setFilter("nearest", "nearest")
end

function title:update(dt)

end

function title:handleRescale()

end

function title:keyreleased(key, code)
	if key == "escape" then
		love.event.quit()
	else
		Gamestate.push(game)
	end
end

function title:draw()
	love.graphics.push()
		love.graphics.scale(scaleFactor, scaleFactor)
		love.graphics.draw(self.titleScreen, 0, 0)
	love.graphics.pop()
end

return title