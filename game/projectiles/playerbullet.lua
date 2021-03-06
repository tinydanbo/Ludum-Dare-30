Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Entity = require "framework.entity"
PlayerBulletImpact = require "game.fx.playerbulletimpact"

PlayerBasicBullet = Class {__includes = Entity,
	init = function(self, player, x, y, dx, dy)
		Entity.init(self, x, y)
		self.type = "playerbullet"
		self.velocity = Vector(dx, dy)
		self.image:setFilter("nearest", "nearest")
		self.player = player
		self.firstFrame = true
		self.lived = 0
		self.lifetime = 3
		self.damage = 1
	end,
	image = love.graphics.newImage("data/graphics/bullet_pilot.png"),
	quad = love.graphics.newQuad(0, 0, 16, 16, 32, 16)
}

function PlayerBasicBullet:registerCollisionData(collider)
	local x,y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-4, y-4, 8, 8)
	self.hitbox.entity = self
end

function PlayerBasicBullet:onHit()
	local impact = PlayerBulletImpact(
		self.position.x,
		self.position.y
	)
	self.manager:addParticle(impact)
	self:destroy()
end

function PlayerBasicBullet:update(dt)
	self.lived = self.lived + dt
	if self.lived > self.lifetime then
		self:destroy()
	end
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
		love.graphics.draw(self.image, self.quad, x, y, 0, 1.5, 1.5, 8, 8)
	end
end

return PlayerBasicBullet