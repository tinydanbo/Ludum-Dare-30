Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Anim8 = require "lib.anim8"
Entity = require "framework.entity"
MachineGun = require "game.weapons.pilot.machinegun"

Player = Class{__includes = Entity,
	init = function(self, x, y)
		Entity.init(self, x, y)
		self.type = "player"
		self.movespeed = 150
		self.gravity = 10
		self.dy = 0
		self.grounded = false
		self.facingLeft = false
		self.weapon = MachineGun(self)
		self.spriteGrid = Anim8.newGrid(
			64, 64, 
			self.spriteSheet:getWidth(), self.spriteSheet:getHeight()
		)
		self.spriteSheet:setFilter("nearest", "nearest")

		self.standRightAnim = Anim8.newAnimation(self.spriteGrid(
			1, 2
		), 0.1)
		self.standLeftAnim = self.standRightAnim:clone():flipH()

		self.runRightAnim = Anim8.newAnimation(self.spriteGrid(
			1, 2,
			2, 2,
			1, 2,
			3, 2
		), 0.2)
		self.runLeftAnim = self.runRightAnim:clone():flipH()

		self.jumpRightAnim = Anim8.newAnimation(self.spriteGrid(
			4, 2
		), 0.1)
		self.jumpLeftAnim = self.jumpRightAnim:clone():flipH()

		self.currentAnim = self.standRightAnim
	end,
	spriteSheet = love.graphics.newImage("data/graphics/player_pilot.png"),
}

function Player:update(dt)
	self.weapon:update(dt)

	local desiredDirection = Vector(0, 0)
	if love.keyboard.isDown("a", "left") then
		desiredDirection.x = -1
		self.facingLeft = true
		self.currentAnim = self.runLeftAnim
	elseif love.keyboard.isDown("d", "right") then
		desiredDirection.x = 1
		self.facingLeft = false
		self.currentAnim = self.runRightAnim
	else
		if self.facingLeft then
			self.currentAnim = self.standLeftAnim
		else
			self.currentAnim = self.standRightAnim
		end
	end

	if love.keyboard.isDown(" ") and self.grounded then
		self.dy = -360
		self.grounded = false
	end

	if love.keyboard.isDown("j", "z") then
		self.weapon:fire()
	end

	if not self.grounded then
		if self.facingLeft then
			self.currentAnim = self.jumpLeftAnim
		else
			self.currentAnim = self.jumpRightAnim
		end
	end

	local movement = desiredDirection * (self.movespeed * dt)
	self:move(movement)

	self.dy = self.dy + self.gravity
	self:move(Vector(0, (self.dy * dt)))

	self.currentAnim:update(dt)
end

function Player:onGrounded()
	self.dy = 0
	self.grounded = true
end

function Player:registerCollisionData(collider)
	local x,y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-4, y-4, 8, 14)
	self.hitbox.entity = self
end

function Player:draw()
	local x,y = self.position:unpack()

	love.graphics.setColor(255, 255, 255)
	self.currentAnim:draw(self.spriteSheet, x, y, 0, 1, 1, 32, 32)
end

return Player