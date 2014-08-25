Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Anim8 = require "lib.anim8"
Entity = require "framework.entity"

FriendlyExplosion = Class {__includes = Entity,
	init = function(self, x, y)
		Entity.init(self, x, y)
		self.type = "playerbullet"
		self.velocity = Vector(dx, dy)
		self.damage = 0.1
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
			1, 2,
			2, 2,
			3, 2
		), math.random(3, 5) / 100, function()
			self:destroy()
		end)

	end,
	spriteSheet = love.graphics.newImage("data/graphics/Explosion 1.png"),
}

function FriendlyExplosion:onHit()
	-- wooooowww
end

function FriendlyExplosion:registerCollisionData(collider)
	local x, y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-8, y-8, 16, 16)
	self.hitbox.entity = self
end

function FriendlyExplosion:update(dt)
	self.animation:update(dt)
end

function FriendlyExplosion:draw()
	local x,y  = self.position:unpack()
	love.graphics.setColor(255, 255, 255, 255)
	self.animation:draw(self.spriteSheet, x, y, 0, 1.5, 1.5, 16, 16)
end

return FriendlyExplosion