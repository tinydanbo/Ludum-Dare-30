Gamestate = require "lib.hump.gamestate"
Anim8 = require "lib.anim8"
Timer = require "lib.hump.timer"
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

	self.popcornSpritesheet = love.graphics.newImage("data/graphics/enemy_popcorn.png")
	self.popcornSpritesheet:setFilter("nearest", "nearest")

	self.popcornSpriteGrid = Anim8.newGrid(
		64, 64,
		self.popcornSpritesheet:getWidth(), self.popcornSpritesheet:getHeight()
	)

	self.popcornAnim = Anim8.newAnimation(self.popcornSpriteGrid(
		1, 1,
		2, 1,
		3, 1,
		4, 1,
		5, 1
	), 0.2)

	self.messages = {
		"Hello everyone!",
		"My designation is AD-Y72, but everyone calls me 'Popcorn Enemy'!",
		"Even my boss calls me that, which is a bit...",
		"Anyway! I've been working really hard, and so have the developers!",
		"So, if you liked the game, could you please give it a good rating? (eheee)",
		"In return, I'll tell you a secret!",
		"If you press P at the title screen, you'll get a secret 10-wave mode!",
		"It might be broken, so don't tell anyone...",
		"See you next time!"
	}

	self.blipSound = love.audio.newSource("data/sfx/blip.wav", "static")

	self.currentMessage = ""
	self.letters = 0
	self.desiredMessage = self.messages[1]
	self.desiredIndex = 1
	self.readyForNext = false

	self.font = love.graphics.newFont("data/font/04B_03__.TTF", 8)
	self.font:setFilter("nearest", "nearest")

	self.timer = Timer.new()
	self.timer:addPeriodic(0.02, function()
		self:updateText()
	end)
end

function bonus:updateText()
	if self.letters < string.len(self.desiredMessage) then
		self.letters = self.letters + 1
		self.currentMessage = string.sub(self.desiredMessage, 0, self.letters)
		self.blipSound:rewind()
		self.blipSound:play()
	else
		self.readyForNext = true
	end
end

function bonus:update(dt)
	self.elapsed = self.elapsed + dt
	self.timer:update(dt)

	self.backgroundNearAnimation:update(dt)
	self.popcornAnim:update(dt)
end

function bonus:handleRescale()

end

function bonus:keyreleased(key, code)
	if self.readyForNext then
		if self.desiredIndex >= #self.messages then
			Gamestate.switch(thanksState)
			return
		else
			self.currentMessage = ""
			self.letters = 0
			self.desiredIndex = self.desiredIndex + 1
			self.desiredMessage = self.messages[self.desiredIndex]
			self.readyForNext = false
		end
	end
end

function bonus:draw()
	love.graphics.push()
		love.graphics.scale(scaleFactor, scaleFactor)
		love.graphics.draw(self.backgroundSky, 0, 0)
		love.graphics.draw(self.backgroundFar, 0, 0)
		self.backgroundNearAnimation:draw(self.backgroundNear, 0, 0)
		love.graphics.draw(self.pedestal, 0, 0)

		self.popcornAnim:draw(self.popcornSpritesheet, 120, 70+math.sin(self.elapsed)*8, 0, 1, 1, 32, 32)
	
		love.graphics.setFont(self.font)
		love.graphics.setColor(0, 0, 0, 255)
			love.graphics.printf(self.currentMessage, 0+1, 130+1, 240, "center")
			love.graphics.printf(self.currentMessage, 0+1, 130, 240, "center")
			love.graphics.printf(self.currentMessage, 0+1, 130-1, 240, "center")
			love.graphics.printf(self.currentMessage, 0, 130+1, 240, "center")
			love.graphics.printf(self.currentMessage, 0, 130-1, 240, "center")
			love.graphics.printf(self.currentMessage, 0-1, 130+1, 240, "center")
			love.graphics.printf(self.currentMessage, 0-1, 130, 240, "center")
			love.graphics.printf(self.currentMessage, 0-1, 130-1, 240, "center")
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.printf(self.currentMessage, 0, 130, 240, "center")
	love.graphics.pop()
end

return bonus