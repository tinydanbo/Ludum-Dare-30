Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Entity = require "framework.entity"

PlayerBasicBullet = Class {__includes = Entity,
	init = function(self, player, x, y, dx, dy)
		Entity.init(self, x, y)
		self.type = "playerbullet"
		self.velocity = Vector(dx, dy)
		self.image:setFilter("nearest", "nearest")
		self.player = player
		self.firstFrame = true
	end,
	image = love.graphics.newImage("data/graphics/bullet_pilot.png"),
	quad = love.graphics.newQuad(0, 0, 16, 16, 32, 16)
}

function PlayerBasicBullet:registerCollisionData(collider)
	local x,y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-2, y-2, 4, 4)
	self.hitbox.entity = self
end

function PlayerBasicBullet:update(dt)
	self:move(self.velocity * dt)
end

function PlayerBasicBullet:draw()
	local x, y = self.position:unpack()

	if self.firstFrame then
		love.graphics.setColor(255, 255, 200, 200)
		love.graphics.circle("fill", x, y, 8)
		self.firstFrame = false
	else
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.image, self.quad, x, y, 0, 1, 1, 8, 8)
	end
end

return PlayerBasicBullet