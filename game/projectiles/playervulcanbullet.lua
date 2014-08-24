Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Entity = require "framework.entity"
PlayerBulletImpact = require "game.fx.playerbulletimpact"

PlayerVulcanBullet = Class {__includes = Entity,
	init = function(self, player, x, y, dx, dy)
		Entity.init(self, x, y)
		self.type = "playerbullet"
		self.velocity = Vector(dx, dy)
		self.image:setFilter("nearest", "nearest")
		self.player = player
		self.firstFrame = true
		self.lived = 0
		self.lifetime = 3
		self.damage = 2
	end,
	image = love.graphics.newImage("data/graphics/bullet_gatling.png"),
}

function PlayerVulcanBullet:registerCollisionData(collider)
	local x,y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-5, y-3, 8, 6)
	self.hitbox.entity = self
end

function PlayerVulcanBullet:onHit()
	local impact = PlayerBulletImpact(
		self.position.x,
		self.position.y
	)
	self.manager:addParticle(impact)
	self:destroy()
end

function PlayerVulcanBullet:update(dt)
	self.lived = self.lived + dt
	if self.lived > self.lifetime then
		self:destroy()
	end
	self:move(self.velocity * dt)
end

function PlayerVulcanBullet:draw()
	local x, y = self.position:unpack()

	if self.firstFrame then
		love.graphics.setColor(255, 100, 100, 200)
		love.graphics.circle("fill", x, y, 6)
		self.firstFrame = false
	else
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.image, x, y, 0, 2, 2, 3, 2)
	end
end

return PlayerVulcanBullet