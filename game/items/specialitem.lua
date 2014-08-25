Class = require "lib.hump.class"
Gamestate = require "lib.hump.gamestate"
Vector = require "lib.hump.vector"
Entity = require "framework.entity"

SpecialItem = Class{__includes = Entity,
	init = function(self, x, y)
		Entity.init(self, x, y)
		self.type = "item"
		self.itemtype = math.random(1,3)
		self.draworder = 4
		self.size = size
		self.lived = 0
		self.lifetime = 10
		self.frozen = false
		self.velocity = Vector(math.random(-50, 50), math.random(-80, -50))
		self.spriteSheet:setFilter("nearest", "nearest")
		self.quad = self.quads[self.itemtype]
	end,
	spriteSheet = love.graphics.newImage("data/graphics/pickup_data.png"),
	quads = {
		love.graphics.newQuad(16*0, 0, 16, 16, 16*8, 16),
		love.graphics.newQuad(16*1, 0, 16, 16, 16*8, 16),
		love.graphics.newQuad(16*2, 0, 16, 16, 16*8, 16)
	}
}

function SpecialItem:freeze()
	self.frozen = true
end

function SpecialItem:update(dt)
	if not self.frozen then
		self.velocity.y = self.velocity.y + 10
		self:move(self.velocity * dt)
	end
	self.lived = self.lived + dt
	if self.lived > self.lifetime then
		self:destroy()
	end
end

function SpecialItem:registerCollisionData(collider)
	local x,y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-3, y-3, 6, 6)
	self.hitbox.entity = self
end

function SpecialItem:draw()
	local x,y = self.position:unpack()

	love.graphics.draw(self.spriteSheet, self.quad, x, y, 0, 1, 1, 8, 8)
end

return SpecialItem