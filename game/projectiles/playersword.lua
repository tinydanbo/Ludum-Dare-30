Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Anim8 = require "lib.anim8"
Entity = require "framework.entity"
Sparkle = require "game.fx.sparkle"

PlayerSword = Class {__includes = Entity,
	init = function(self, player, x, y, dx, dy)
		Entity.init(self, x, y)
		self.type = "playerbullet"
		self.velocity = Vector(dx, dy)
		self.spriteSheet:setFilter("nearest", "nearest")
		self.player = player
		self.firstFrame = true
		self.particleEmitCounter = 0
		self.particleEmitRate = 0.15
		self.damage = 2
		self.gravity = 0
		self.decay = decay
		self.lived = 0
		self.lifetime = 5
		self.spriteGrid = Anim8.newGrid(
			32, 32,
			self.spriteSheet:getWidth(), self.spriteSheet:getHeight()
		)

		self.spinAnim = Anim8.newAnimation(self.spriteGrid(
			1, 1,
			2, 1,
			3, 1,
			4, 1,
			5, 1,
			6, 1,
			7, 1
		), 0.04)
	end,
	spriteSheet = love.graphics.newImage("data/graphics/Missile.png")
}

function PlayerSword:registerCollisionData(collider)
	local x,y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-4, y-4, 8, 8)
	self.hitbox.entity = self
end

function PlayerSword:onHit()
	-- self:destroy()
end

function PlayerSword:update(dt)
	self.particleEmitCounter = self.particleEmitCounter + dt
	if self.particleEmitCounter > self.particleEmitRate then
		self.particleEmitCounter = 0
		local sparkle = Sparkle(
			self.position.x,
			self.position.y,
			0,
			0
		)
		self.player.manager:addParticle(sparkle)
	end

	self.velocity.y = self.velocity.y + (self.gravity * dt)
	self.lived = self.lived + dt
	if self.lived > self.lifetime then
		self:destroy()
	end
	self:move(self.velocity * dt)
	self.spinAnim:update(dt)
end

function PlayerSword:draw()
	local x, y = self.position:unpack()

	--[[
	if self.firstFrame then
		love.graphics.setColor(255, 255, 200, 200)
		love.graphics.circle("fill", x, y, 8)
		self.firstFrame = false
	else
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(self.image, self.quad, x, y, 0, 1.5, 1.5, 8, 8)
	end
	]]--

	love.graphics.setColor(255, 255, 255, 255)
	self.spinAnim:draw(self.spriteSheet, x, y, 0, 1, 1, 16, 16)
end

return PlayerSword