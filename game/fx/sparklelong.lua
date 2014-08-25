Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Anim8 = require "lib.anim8"
Entity = require "framework.entity"

SparkleLong = Class {__includes = Entity,
	init = function(self, x, y, dx, dy)
		Entity.init(self, x, y)
		self.velocity = Vector(dx, dy)
		self.spriteGrid = Anim8.newGrid(
			32, 32,
			self.spriteSheet:getWidth(), self.spriteSheet:getHeight()
		)
		self.spriteSheet:setFilter("nearest", "nearest")

		self.animation = Anim8.newAnimation(self.spriteGrid(
			1, 1,
			2, 1,
			3, 1,
			4, 1,
			5, 1,
			6, 1,
			7, 1,
			8, 1,
			9, 1,
			10, 1,
			11, 1,
			12, 1,
			13, 1,
			14, 1
		), 0.05, function()
			self:destroy()
		end)

	end,
	spriteSheet = love.graphics.newImage("data/graphics/Sparkle Long.png"),
}

function SparkleLong:update(dt)
	self.animation:update(dt)
	self.position = self.position + (self.velocity * dt)
end

function SparkleLong:draw()
	local x,y  = self.position:unpack()
	love.graphics.setColor(255, 255, 255, 255)
	self.animation:draw(self.spriteSheet, x, y, 0, 1, 1, 16, 16)
end

return SparkleLong