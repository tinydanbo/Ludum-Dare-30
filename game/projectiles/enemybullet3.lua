Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Entity = require "framework.entity"

EnemyBasicBulletThree = Class {__includes = Entity,
	init = function(self, owner, x, y, dx, dy)
		Entity.init(self, x, y)
		self.type = "enemybullet"
		self.velocity = Vector(dx, dy)
		self.image:setFilter("nearest", "nearest")
		self.owner = owner
		self.lived = 0
		self.lifetime = 3
		self.damage = 10
		self.quad = love.graphics.newQuad(16, 0, 16, 16, 80, 32)
	end,
	image = love.graphics.newImage("data/graphics/bullet_enemy.png")
}

function EnemyBasicBulletThree:registerCollisionData(collider)
	local x,y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-2, y-6, 4, 12)
	self.hitbox.entity = self
end

function EnemyBasicBulletThree:update(dt)
	self.lived = self.lived + dt
	if self.lived > self.lifetime then
		self:destroy()
	end
	self:move(self.velocity * dt)
end

function EnemyBasicBulletThree:draw()
	local x, y = self.position:unpack()

	local rotation = math.atan2(self.velocity.y, self.velocity.x)

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.image, self.quad, x, y, 0, -1, 1, 8, 8)
end

return EnemyBasicBulletThree