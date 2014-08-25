Gamestate = require "lib.hump.gamestate"
Anim8 = require "lib.anim8"
thanksState = require "game.states.thanks"

local bonus = {}

function bonus:enter(oldState)
	self.elapsed = 0

	self.backgroundSky = love.graphics.newImage("data/graphics/Background SKY.png")
	self.backgroundSky:setFilter("nearest", "nearest")

	self.backgroundFar = love.graphics.newImage("data/graphics/Background 2ndary.png")
	self.backgroundFar:setFilter("nearest", "nearest")

	self.backgroundNear = love.graphics.newImage("data/graphics/Background Animation2.png")
	self.backgroundNear:setFilter("nearest", "nearest")

	self.backgroundNearGrid = Anim8.newGrid(240, 160,
		self.backgroundNear:getWidth(), self.backgroundNear:getHeight()
	)

	self.backgroundNearAnimation = Anim8.newAnimation(
		self.backgroundNearGrid(
			1, 1,
			2, 1,
			3, 1,
			2, 1
		), 0.5
	)

	self.pedestal = love.graphics.newImage("data/graphics/pedestal.png")
	self.pedestal:setFilter("nearest", "nearest")
end

function bonus:update(dt)
	self.elapsed = self.elapsed + dt

	self.backgroundNearAnimation:update(dt)
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
		love.graphics.draw(self.backgroundSky, 0, 0)
		love.graphics.draw(self.backgroundFar, 0, 0)
		self.backgroundNearAnimation:draw(self.backgroundNear, 0, 0)
		love.graphics.draw(self.pedestal, 0, 0)
	love.graphics.pop()
end

return bonus