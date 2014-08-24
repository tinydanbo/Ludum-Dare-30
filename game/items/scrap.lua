Class = require "lib.hump.class"
Gamestate = require "lib.hump.gamestate"
Vector = require "lib.hump.vector"
Entity = require "framework.entity"

ScrapMetal = Class{__includes = Entity,
	init = function(self, x, y, size)
		Entity.init(self, x, y)
		self.type = "item"
		self.velocity = Vector(math.random(-30, 30), math.random(-20, -10))
		self.spriteSheet:setFilter("nearest", "nearest")
		self.quad =
	end,
	spriteSheet = love.graphics.newImage("data/graphics/pickup_data.png")
	quads = {
		love.graphics.newQuad(16*3, 0, 16, 16, 16*8, 16),
		love.graphics.newQuad(16*4, 0, 16, 16, 16*8, 16),
		love.graphics.newQuad(16*5, 0, 16, 16, 16*8, 16),
		love.graphics.newQuad(16*6, 0, 16, 16, 16*8, 16),
		love.graphics.newQuad(16*7, 0, 16, 16, 16*8, 16),
	}
}