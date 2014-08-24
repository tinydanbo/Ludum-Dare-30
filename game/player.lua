Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Anim8 = require "lib.anim8"
Entity = require "framework.entity"
MachineGun = require "game.weapons.pilot.machinegun"

Player = Class{__includes = Entity,
	init = function(self, x, y)
		Entity.init(self, x, y)
		self.type = "player"
		self.active = true
		self.movespeed = 150
		self.gravity = 10
		self.dy = 0
		self.grounded = false
		self.facingLeft = false
		self.aimDirection = Vector(1, 0)
		self.velocity = Vector(0, 0)
		self.weapon = MachineGun(self)
		self.spriteGrid = Anim8.newGrid(
			64, 64, 
			self.spriteSheet:getWidth(), self.spriteSheet:getHeight()
		)
		self.spriteGrid2 = Anim8.newGrid(
			64, 64,
			self.spriteSheet2:getWidth(), self.spriteSheet2:getHeight()
		)
		self.spriteSheet:setFilter("nearest", "nearest")
		self.spriteSheet2:setFilter("nearest", "nearest")

		self.standRightAnim = Anim8.newAnimation(self.spriteGrid(
			1, 2
		), 0.1)
		self.standLeftAnim = self.standRightAnim:clone():flipH()

		self.standRightAimUpAnim = Anim8.newAnimation(self.spriteGrid2(
			1, 3
		), 0.1)
		self.standLeftAimUpAnim = self.standRightAimUpAnim:clone():flipH()

		self.runRightAnim = Anim8.newAnimation(self.spriteGrid(
			1, 2,
			2, 2,
			1, 2,
			3, 2
		), 0.1)
		self.runLeftAnim = self.runRightAnim:clone():flipH()

		self.runRightAimUpAnim = Anim8.newAnimation(self.spriteGrid2(
			1, 1,
			2, 1,
			1, 1,
			3, 1
		), 0.1)
		self.runLeftAimUpAnim = self.runRightAimUpAnim:clone():flipH()

		self.runRightAimDownAnim = Anim8.newAnimation(self.spriteGrid2(
			1, 2,
			2, 2,
			1, 2,
			3, 2
		), 0.1)
		self.runLeftAimDownAnim = self.runRightAimDownAnim:clone():flipH()

		self.standRightAimDownAnim = Anim8.newAnimation(self.spriteGrid2(
			1, 2
		), 0.1)
		self.standLeftAimDownAnim = self.standRightAimDownAnim:clone():flipH()

		self.jumpRightAnim = Anim8.newAnimation(self.spriteGrid(
			4, 2
		), 0.1)
		self.jumpLeftAnim = self.jumpRightAnim:clone():flipH()

		self.currentAnim = self.standRightAnim
	end,
	spriteSheet = love.graphics.newImage("data/graphics/player_pilot.png"),
	spriteSheet2 = love.graphics.newImage("data/graphics/player_pilot_2.png")
}

function Player:updateAimDirection()
	if love.keyboard.isDown("a", "left") then
		self.aimDirection.x = -1
	elseif love.keyboard.isDown("d", "right") then
		self.aimDirection.x = 1
	elseif love.keyboard.isDown("w", "up") then
		self.aimDirection.x = 0
	elseif love.keyboard.isDown("s", "down") and not self.grounded then
		self.aimDirection.x = 0
	end

	if love.keyboard.isDown("w", "up") then
		self.aimDirection.y = -1
	elseif love.keyboard.isDown("s", "down") then
		self.aimDirection.y = 1
	else
		self.aimDirection.y = 0
	end

	if self.aimDirection == Vector(0, 0) then
		if self.facingLeft then
			self.aimDirection = Vector(-1, 0)
		else
			self.aimDirection = Vector(1, 0)
		end
	end
end

function Player:getDesiredCameraPosition()
	return self.position
end

function Player:update(dt)
	self.weapon:update(dt)
	if self.active then
		self:updateAimDirection()
	end
	self:checkIsGrounded()

	local desiredDirection = Vector(0, 0)
	if self.active then
		if love.keyboard.isDown("a", "left") then
			desiredDirection.x = -1
			self.facingLeft = true
			if self.aimDirection.y == -1 then
				self.currentAnim = self.runLeftAimUpAnim
			elseif self.aimDirection.y == 1 then
				self.currentAnim = self.runLeftAimDownAnim
			else
				self.currentAnim = self.runLeftAnim
			end
		elseif love.keyboard.isDown("d", "right") then
			desiredDirection.x = 1
			self.facingLeft = false
			if self.aimDirection.y == -1 then
				self.currentAnim = self.runRightAimUpAnim
			elseif self.aimDirection.y == 1 then
				self.currentAnim = self.runRightAimDownAnim
			else
				self.currentAnim = self.runRightAnim
			end
		else
			if self.facingLeft then
				if self.aimDirection.y == -1 then
					self.currentAnim = self.standLeftAimUpAnim
				elseif self.aimDirection.y == 1 then
					self.currentAnim = self.standLeftAimDownAnim
				else
					self.currentAnim = self.standLeftAnim
				end
			else
				if self.aimDirection.y == -1 then
					self.currentAnim = self.standRightAimUpAnim
				elseif self.aimDirection.y == 1 then
					self.currentAnim = self.standRightAimDownAnim
				else
					self.currentAnim = self.standRightAnim
				end
			end
		end
	end

	if love.keyboard.isDown("j", "z") and self.active then
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

	self.velocity = desiredDirection * self.movespeed

	self.dy = self.dy + self.gravity
	self:move(Vector(0, (self.dy * dt)))

	self.currentAnim:update(dt)
end

function Player:getFireOffset()
	if self.aimDirection.x == 1 and self.aimDirection.y == 0 then
		return Vector(6, 3)
	elseif self.aimDirection.x == -1 and self.aimDirection.y == 0 then
		return Vector(-6, 3)
	elseif self.aimDirection.x == 1 and self.aimDirection.y == -1 then
		return Vector(4, 0)
	elseif self.aimDirection.x == -1 and self.aimDirection.y == -1 then
		return Vector(-4, 0)
	elseif self.aimDirection.x == 0 and self.aimDirection.y == -1 then
		if self.facingLeft then
			return Vector(-2, -6)
		else
			return Vector(2, -6)
		end
	elseif self.aimDirection.x == -1 and self.aimDirection.y == 1 then
		return Vector(-6, 4)
	elseif self.aimDirection.x == 1 and self.aimDirection.y == 1 then
		return Vector(6, 4)
	end
	return Vector(0, 0)
end

function Player:checkIsGrounded()
	local x,y = self.position:unpack()
	local isGrounded = false

	for _, shape in ipairs(self.manager.collider:shapesAt(x, y+11)) do
		if shape.entity.type == "solid" then
			isGrounded = true
		end
	end

	self.grounded = isGrounded
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

function Player:keypressed(key, code)
	if key == " " and self.active and self.grounded then
		self.dy = -180
		self.grounded = false
	end
end

function Player:draw()
	local x,y = self.position:unpack()

	if self.active then
		love.graphics.setColor(255, 255, 255)
	else
		love.graphics.setColor(180, 100, 100)
	end

	-- "yikes"
	if self.currentAnim == self.runRightAimUpAnim or
		self.currentAnim == self.runLeftAimUpAnim or 
		self.currentAnim == self.standLeftAimUpAnim or
		self.currentAnim == self.standRightAimUpAnim or
		self.currentAnim == self.runLeftAimDownAnim or
		self.currentAnim == self.runRightAimDownAnim or
		self.currentAnim == self.standRightAimDownAnim or
		self.currentAnim == self.standLeftAimDownAnim then
		self.currentAnim:draw(self.spriteSheet2, x, y, 0, 1, 1, 32, 32)
	else
		self.currentAnim:draw(self.spriteSheet, x, y, 0, 1, 1, 32, 32)
	end
end

return Player