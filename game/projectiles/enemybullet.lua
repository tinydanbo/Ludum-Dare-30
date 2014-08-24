Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Entity = require "framework.entity"

EnemyBasicBullet = Class {__includes = Entity,
	init = function(self, owner, x, y, dx, dy)
		Entity.init(self, x, y)
		self.type = "enemybullet"
		self.velocity = Vector(dx, dy)
		self.image:setFilter("nearest", "nearest")
		self.owner = owner
		self.lived = 0
		self.lifetime = 3
		self.damage = 1
	end,
	image = love.graphics.newImage("data/graphics/bullet_enemy.png"),
	quad = love.graphics.newQuad(0, 0, 16, 16, 80, 32)
}

function EnemyBasicBullet:registerCollisionData(collider)
	local x,y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-4, y-4, 8, 8)
	self.hitbox.entity = self
end

function EnemyBasicBullet:update(dt)
	self.lived = self.lived + dt
	if self.lived > self.lifetime then
		self:destroy()
	end
	self:move(self.velocity * dt)
end

function EnemyBasicBullet:draw()
	local x, y = self.position:unpack()

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.image, self.quad, x, y, 0, 1.5, 1.5, 8, 8)
end

return EnemyBasicBullet