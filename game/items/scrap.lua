Class = require "lib.hump.class"
Gamestate = require "lib.hump.gamestate"
Vector = require "lib.hump.vector"
Entity = require "framework.entity"

ScrapMetal = Class{__includes = Entity,
	init = function(self, x, y, size)
		Entity.init(self, x, y)
		self.type = "item"
		self.draworder = 4
		self.size = size
		self.lived = 0
		self.lifetime = 10
		self.frozen = false
		self.velocity = Vector(math.random(-300, 300), math.random(-80, -50))
		self.spriteSheet:setFilter("nearest", "nearest")
		self.quad = self.quads[size]
	end,
	spriteSheet = love.graphics.newImage("data/graphics/pickup_data.png"),
	quads = {
		love.graphics.newQuad(16*3, 0, 16, 16, 16*8, 16),
		love.graphics.newQuad(16*4, 0, 16, 16, 16*8, 16),
		love.graphics.newQuad(16*5, 0, 16, 16, 16*8, 16),
		love.graphics.newQuad(16*6, 0, 16, 16, 16*8, 16),
		love.graphics.newQuad(16*7, 0, 16, 16, 16*8, 16),
	}
}

function ScrapMetal:freeze()
	self.frozen = true
end

function ScrapMetal:update(dt)
	if not self.frozen then
		self.velocity.y = self.velocity.y + 10
		self:move(self.velocity * dt)
	end
	self.lived = self.lived + dt
	if self.lived > self.lifetime then
		self:destroy()
	end
end

function ScrapMetal:registerCollisionData(collider)
	local x,y = self.position:unpack()
	print("ey")

	self.hitbox = collider:addRectangle(x-2, y-3, 4, 3)
	self.hitbox.entity = self
end

function ScrapMetal:draw()
	local x,y = self.position:unpack()

	love.graphics.draw(self.spriteSheet, self.quad, x, y, 0, 1, 1, 8, 8)
end

return ScrapMetal