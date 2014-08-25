Gamestate = require "lib.hump.gamestate"
Timer = require "lib.hump.timer"
game = require "game.states.game" ---a hah ah ah ah aha

local title = {}

function title:enter(oldState)
	self.titleScreen = love.graphics.newImage("data/graphics/screen_title.png")
	self.titleScreen:setFilter("nearest", "nearest")
	self.promptScreen = love.graphics.newImage("data/graphics/screen_prompt.png")
	self.promptScreen:setFilter("nearest", "nearest")
	self.state = 1
	self.locked = false
end

function title:update(dt)
	Timer.update(dt)
end

function title:handleRescale()

end

function title:keyreleased(key, code)
	if key == "escape" then
		love.event.quit()
	else
		if not self.locked then
			if self.state == 1 then
				self.state = 2
				self.locked = true
				Timer.add(1, function()
					self.locked = false
				end)
			else
				Gamestate.push(game)
				self.state = 1
				self.locked = false
			end
		end
	end
end

function title:draw()
	love.graphics.push()
		love.graphics.scale(scaleFactor, scaleFactor)
		if self.state == 1 then
			love.graphics.draw(self.titleScreen, 0, 0)
		else
			love.graphics.draw(self.promptScreen, 0, 0)
		end
	love.graphics.pop()
end

return title