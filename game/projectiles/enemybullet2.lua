Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Entity = require "framework.entity"

EnemyBasicBulletTwo = Class {__includes = Entity,
	init = function(self, owner, x, y, dx, dy)
		Entity.init(self, x, y)
		self.type = "enemybullet"
		self.velocity = Vector(dx, dy)
		self.image:setFilter("nearest", "nearest")
		self.owner = owner
		self.lived = 0
		self.lifetime = 3
		self.damage = 6
		if math.random(0, 10) > 5 then
			self.quad = love.graphics.newQuad(16, 16, 16, 16, 80, 32)
			self.rotationoffset = math.rad(90)
		else
			self.quad = love.graphics.newQuad(32, 16, 16, 16, 80, 32)
			self.rotationoffset = math.rad(180)
		end
	end,
	image = love.graphics.newImage("data/graphics/bullet_enemy.png")
}

function EnemyBasicBulletTwo:registerCollisionData(collider)
	local x,y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-3, y-3, 6, 6)
	self.hitbox.entity = self
end

function EnemyBasicBulletTwo:update(dt)
	self.lived = self.lived + dt
	if self.lived > self.lifetime then
		self:destroy()
	end
	self:move(self.velocity * dt)
end

function EnemyBasicBulletTwo:draw()
	local x, y = self.position:unpack()

	local rotation = math.atan2(self.velocity.y, self.velocity.x)

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.image, self.quad, x, y, rotation + self.rotationoffset, 1, 1, 8, 8)
end

return EnemyBasicBulletTwo