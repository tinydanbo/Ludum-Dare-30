Gamestate = require "lib.hump.gamestate"
thanksState = require "game.states.thanks"

local bonus = {}

function bonus:enter(oldState)
	self.elapsed = 0
end

function bonus:update(dt)
	self.elapsed = self.elapsed + dt
end

function bonus:handleRescale()

end

function bonus:keyreleased(key, code)
	if self.elapsed > 2 then
		Gamestate.switch(thanksState)
	end
end

function bonus:draw()
	love.graphics.push()
		love.graphics.scale(scaleFactor, scaleFactor)
	love.graphics.pop()
end

return bonus