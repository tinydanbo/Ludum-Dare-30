Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Anim8 = require "lib.anim8"
Entity = require "framework.entity"

PlayerMech = Class{__includes = Entity,
	init = function(self, x, y)
		Entity.init(self, x, y)
		self.type = "playermech"
		self.active = false
		self.gravity = 20
		self.dy = 0
		self.spriteGrid = Anim8.newGrid(
			128, 128,
			self.spriteSheet:getWidth(), self.spriteSheet:getHeight()
		)
		self.spriteSheet:setFilter("nearest", "nearest")
		self.armSpriteSheet:setFilter("nearest", "nearest")

		self.standRightAnim = Anim8.newAnimation(self.spriteGrid(
			1, 1
		), 0.1)
		self.standLeftAnim = self.standRightAnim:clone():flipH()

		self.currentAnim = self.standRightAnim

		self.armForwardQuad = love.graphics.newQuad(
			0, 0, 
			128, 128, 
			self.armSpriteSheet:getWidth(), self.armSpriteSheet:getHeight()
		)
	end,
	spriteSheet = love.graphics.newImage("data/graphics/player_mech.png"),
	armSpriteSheet = love.graphics.newImage("data/graphics/player_mech_arm.png")
}

function PlayerMech:getDesiredCameraPosition()
	return self.position
end

function PlayerMech:update(dt)
	self.dy = self.dy + self.gravity
	self:move(Vector(0, (self.dy * dt)))

	self.currentAnim:update(dt)
end

function PlayerMech:onGrounded()
	self.dy = 0
	self.grounded = true
end

function PlayerMech:registerCollisionData(collider)
	local x,y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-10, y-16, 16, 34)
	self.hitbox.entity = self
end

function PlayerMech:draw()
	local x,y = self.position:unpack()

	if self.active then
		love.graphics.setColor(255, 255, 255)
	else
		love.graphics.setColor(100, 100, 180)
	end
	self.currentAnim:draw(self.spriteSheet, x, y, 0, 1, 1, 64, 64)
	love.graphics.draw(self.armSpriteSheet, self.armForwardQuad, x-8, y-8, 0, 1, 1, 64, 64)
end

return PlayerMech