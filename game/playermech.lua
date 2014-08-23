Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Timer = require "lib.hump.timer"
Anim8 = require "lib.anim8"
Entity = require "framework.entity"
Particle = require "game.fx.particle"

PlayerMech = Class{__includes = Entity,
	init = function(self, x, y)
		Entity.init(self, x, y)
		self.type = "playermech"
		self.active = false
		self.gravity = 20
		self.movespeed = 100
		self.jumppower = 0
		self.grounded = false
		self.jumpchargespeed = 500
		self.maxjump = 500
		self.dy = 0
		self.dx = 0
		self.facingLeft = false
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

		self.walkRightAnim = Anim8.newAnimation(self.spriteGrid(
			1, 1,
			2, 1,
			1, 1,
			3, 1
		), 0.2)
		self.walkLeftAnim = self.walkRightAnim:clone():flipH()

		self.jumpPrepareRightAnim = Anim8.newAnimation(self.spriteGrid(
			4, 1
		), 0.3)
		self.jumpPrepareLeftAnim = self.jumpPrepareRightAnim:clone():flipH()

		self.jumpRightAnim = Anim8.newAnimation(self.spriteGrid(
			5, 1
		), 0.3)
		self.jumpLeftAnim = self.jumpRightAnim:clone():flipH()

		self.fallRightAnim = Anim8.newAnimation(self.spriteGrid(
			6, 1
		), 0.3)
		self.fallLeftAnim = self.fallRightAnim:clone():flipH()

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
	self:checkIsGrounded()

	local desiredDirection = Vector(0, 0)
	if self.active then
		if love.keyboard.isDown("a", "left") and self.grounded then
			desiredDirection.x = -1
			self.facingLeft = true
			self.currentAnim = self.walkLeftAnim
		elseif love.keyboard.isDown("d", "right") and self.grounded then
			desiredDirection.x = 1
			self.facingLeft = false
			self.currentAnim = self.walkRightAnim
		elseif self.grounded then
			if self.facingLeft then
				self.currentAnim = self.standLeftAnim
			else
				self.currentAnim = self.standRightAnim
			end
		end

		if love.keyboard.isDown(" ") then
			if self.facingLeft then
				self.currentAnim = self.jumpPrepareLeftAnim
			else
				self.currentAnim = self.jumpPrepareRightAnim
			end
			self.jumppower = self.jumppower + (self.jumpchargespeed * dt)
			if self.jumppower > self.maxjump then
				self.jumppower = self.maxjump
			end
			desiredDirection.x = desiredDirection.x * 0.1
		else
			if self.jumppower > 50 then
				if love.keyboard.isDown("a", "left") then
					self.dy = self.jumppower * -1
					self.dx = self.jumppower * -0.5
				elseif love.keyboard.isDown("d", "right") then
					self.dy = self.jumppower * -1
					self.dx = self.jumppower * 0.5
				else
					self.dy = self.jumppower * -1.2
				end

				self.grounded = false

				if self.facingLeft then
					self.currentAnim = self.jumpLeftAnim
				else
					self.currentAnim = self.jumpRightAnim
				end
				self.jumppower = 0
			else
				self.jumppower = 0
			end
		end
	end

	local x,y = self.position:unpack()

	if not self.grounded then
		if self.dy < -100 then
			local boostsmoke = Particle(
				"circle",
				x+math.random(-8, 8),
				y+math.random(-8, 8),
				math.random(-4, 4),
				math.random(-4, 4),
				math.random(1, 3),
				255,
				255,
				255,
				200,
				200
			)
			boostsmoke.draworder = 1
			self.manager:addParticle(boostsmoke)
			if self.dx > 0 then
				self.currentAnim = self.jumpRightAnim
			elseif self.dx < 0 then
				self.currentAnim = self.jumpLeftAnim
			else
				if self.facingLeft then
					self.currentAnim = self.jumpLeftAnim
				else
					self.currentAnim = self.jumpRightAnim
				end
			end
		elseif self.dy > -100 then
			if self.dx > 0 then
				self.currentAnim = self.fallRightAnim
			elseif self.dx < 0 then
				self.currentAnim = self.fallLeftAnim
			else
				if self.facingLeft then
					self.currentAnim = self.fallLeftAnim
				else
					self.currentAnim = self.fallRightAnim
				end
			end
		end
	end

	local movement = desiredDirection * (self.movespeed * dt)
	movement.x = movement.x + (self.dx * dt)
	self:move(movement)

	self.dy = self.dy + self.gravity
	self:move(Vector(0, (self.dy * dt)))

	self.currentAnim:update(dt)
end

function PlayerMech:checkIsGrounded()
	local x,y = self.position:unpack()
	local isGrounded = false

	for _, shape in ipairs(self.manager.collider:shapesAt(x, y+28)) do
		if shape.entity.type == "solid" then
			isGrounded = true
		end
	end

	-- print(isGrounded)
	-- self.grounded = isGrounded
end

function PlayerMech:onGrounded()
	local x, y = self.position:unpack()
	local poundPower = self.dy + self.dx

	--[[
	if poundPower > 210 then
		for i=0,poundPower,40 do
			local particle = Particle(
				"square",
				x+math.random(-16, 16),
				y+math.random(17, 19),
				math.random(-50, 50),
				math.random(-10, -200),
				math.random(2, 4),
				200,
				200,
				200,
				255,
				math.random(200, 300)
			)
			particle.draworder = 5
			self.manager:addParticle(particle)
		end
	end
	]]--
	self.dy = 0
	self.dx = 0
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
	-- love.graphics.draw(self.armSpriteSheet, self.armForwardQuad, x-8, y-8, 0, 1, 1, 64, 64)
end

return PlayerMech