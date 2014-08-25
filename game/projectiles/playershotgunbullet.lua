Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Entity = require "framework.entity"
PlayerBulletImpact = require "game.fx.playerbulletimpact"

PlayerShotgunBullet = Class {__includes = Entity,
	init = function(self, player, x, y, dx, dy, decay)
		Entity.init(self, x, y)
		self.type = "playerbullet"
		self.velocity = Vector(dx, dy)
		self.image:setFilter("nearest", "nearest")
		self.player = player
		self.firstFrame = true
		self.particleEmitCounter = 0
		self.particleEmitRate = 0.1
		self.damage = 1
		self.alpha = 255
		self.decay = decay
	end,
	image = love.graphics.newImage("data/graphics/bullet_pilot.png"),
	quad = love.graphics.newQuad(0, 0, 16, 16, 32, 16)
}

function PlayerShotgunBullet:registerCollisionData(collider)
	local x,y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-5, y-5, 10, 10)
	self.hitbox.entity = self
end

function PlayerShotgunBullet:onHit()
	local impact = PlayerBulletImpact(
		self.position.x,
		self.position.y
	)
	self.manager:addParticle(impact)
	self:destroy()
end

function PlayerShotgunBullet:update(dt)
	self.velocity = self.velocity * (1 - (self.decay * dt))
	self.alpha = self.alpha - (self.decay * dt)
	if self.velocity:len() < 200 then
		self:destroy()
	end
	self:move(self.velocity * dt)
end

function PlayerShotgunBullet:draw()
	local x, y = self.position:unpack()

	if self.firstFrame then
		love.graphics.setColor(255, 255, 200, 200)
		love.graphics.circle("fill", x, y, 8)
		self.firstFrame = false
	else
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(self.image, self.quad, x, y, 0, 1.5, 1.5, 8, 8)
	end
end

return PlayerShotgunBullet