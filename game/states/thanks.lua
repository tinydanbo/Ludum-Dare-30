Gamestate = require "lib.hump.gamestate"

local thanks = {}

function thanks:enter(oldState)
	self.titleScreen = love.graphics.newImage("data/graphics/screen_thanks.png")
	self.titleScreen:setFilter("nearest", "nearest")
	self.elapsed = 0
end

function thanks:update(dt)
	self.elapsed = self.elapsed + dt
end

function thanks:handleRescale()

end

function thanks:keyreleased(key, code)
	if self.elapsed > 2 then
		Gamestate.pop()
	end
end

function thanks:draw()
	love.graphics.push()
		love.graphics.scale(scaleFactor, scaleFactor)
		love.graphics.draw(self.titleScreen, 0, 0)
	love.graphics.pop()
end

return thanks