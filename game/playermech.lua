Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Timer = require "lib.hump.timer"
Anim8 = require "lib.anim8"
Entity = require "framework.entity"
Particle = require "game.fx.particle"
Gamestate = require "lib.hump.gamestate"
VulcanCannon = require "game.weapons.mech.vulcancannon"
SparkleLong = require "game.fx.sparklelong"
RedShine = require "game.fx.redshine"

PlayerMech = Class{__includes = Entity,
	init = function(self, x, y)
		Entity.init(self, x, y)
		self.type = "playermech"
		self.active = false
		self.warpingIn = false
		self.shinecounter = 0
		self.shinerate = 0.1
		self.locked = false
		self.gravity = 20
		self.movespeed = 150
		self.jumppower = 0
		self.weapon = VulcanCannon(self)
		self.grounded = false
		self.jumpchargespeed = 1000
		self.maxjump = 500
		self.invisible = false
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

		self.swordRightAnim = Anim8.newAnimation(self.spriteGrid(
			1, 2,
			2, 2,
			3, 2,
			4, 2,
			5, 2,
			6, 2
		), 0.05, "pauseAtEnd")
		self.swordLeftAnim = self.swordRightAnim:clone():flipH()

		self.kneelAnim = Anim8.newAnimation(self.spriteGrid(
			7, 2
		), 0.5)

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

function PlayerMech:changeAnimation(animation, frame)
	self.currentAnim = animation
	animation:gotoFrame(frame)
	animation:resume()
end

function PlayerMech:getDesiredCameraPosition()
	return self.position
end

function PlayerMech:update(dt)
	self:checkIsGrounded()
	self.weapon:update(dt)

	self.shinecounter = self.shinecounter + dt
	if self.shinecounter > self.shinerate and not self.warpingIn and self.active then
		self.shinecounter = 0
		local redshine = RedShine(
			self.position.x + math.random(-16, 16),
			self.position.y + math.random(-32, 32),
			math.random(-5, 5),
			-100 + math.random(-50, 50)
		)
		self.manager:addParticle(redshine)
	end

	local desiredDirection = Vector(0, 0)
	if self.active and not self.locked then
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
					self.facingLeft = true
				elseif love.keyboard.isDown("d", "right") then
					self.dy = self.jumppower * -1
					self.dx = self.jumppower * 0.5
					self.facingLeft = false
				else
					self.dy = self.jumppower * -1
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

	if love.keyboard.isDown("z", "j") and self.active and not self.locked then
		self.weapon:fire()
	end

	local x,y = self.position:unpack()

	if not self.grounded and not self.locked then
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

	if self.locked and not self.dx == 0 and not self.dy == 0 then
		for i=1,3,1 do
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
		end
	end

	local movement = desiredDirection * (self.movespeed * dt)
	movement.x = movement.x + (self.dx * dt)
	self:move(movement)

	self.dy = self.dy + self.gravity
	self:move(Vector(0, (self.dy * dt)))

	self.currentAnim:update(dt)
end

function PlayerMech:warpIn()
	self.locked = true
	self.invisible = true
	self.warpingIn = true
	self.currentAnim = self.kneelAnim
	for i=0, 300, 5 do
		Timer.add(i/100, function()
			Gamestate.current():screenShake(2)
		end)
	end
	Timer.add(0.9, function()
		self.invisible = false
	end)
	for i=0,180,5 do
		Timer.add(1.2+(i/100), function()
			local redshine = RedShine(
				self.position.x + math.random(-8, 8),
				self.position.y + 16,
				math.random(-5, 5),
				-100 + math.random(-50, 50)
			)
			self.manager:addParticle(redshine)
			Gamestate.current():screenShake(6)
		end)
	end
	Timer.add(2.5, function()
		local longspark = SparkleLong(
			self.position.x + 6,
			self.position.y - 6,
			0,
			0
		)
		self.manager:addParticle(longspark)
	end)
	Timer.add(3.2, function()
		self.locked = false
		Gamestate.current():screenShake(20)
		self.warpingIn = false
	end)
end

function PlayerMech:keyreleased(key, code)
	if (key == "c" or key == "l") and not self.locked then
		self.locked = true
		self.gravity = 0
		self.dy = 0
		if love.keyboard.isDown("a", "left") then
			self.dx = -400
			self:changeAnimation(self.swordLeftAnim, 1)
			self.facingLeft = true
		elseif love.keyboard.isDown("d", "right") then
			self.dx = 400
			self:changeAnimation(self.swordRightAnim, 1)
			self.facingLeft = false
		else
			if self.dx < 0 or self.facingLeft then
				self.dx = -400
				self:changeAnimation(self.swordLeftAnim, 1)
				self.facingLeft = true
			else
				self.dx = 400
				self:changeAnimation(self.swordRightAnim, 1)
				self.facingLeft = false
			end
		end
		local mech = self
		Timer.add(0.3, function()
			self.locked = false
			self.gravity = 20
		end)
	end
end

function PlayerMech:getFireOffset()
	if self.facingLeft then
		return self:getArmOffset() + Vector(-26, -4)
	else
		return self:getArmOffset() + Vector(26, -4)
	end
end

function PlayerMech:checkIsGrounded()
	--[[
	local x,y = self.position:unpack()
	local isGrounded = false

	for _, shape in ipairs(self.manager.collider:shapesAt(x, y+28)) do
		if shape.entity.type == "solid" then
			isGrounded = true
		end
	end
	--]]

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

	self.hitbox = collider:addRectangle(x-10, y-12, 16, 30)
	self.hitbox.entity = self
end

function PlayerMech:getArmOffset()
	if self.currentAnim == self.walkLeftAnim then
		local offsets = {
			Vector(0, 0),
			Vector(-1, 2),
			Vector(0, 0),
			Vector(-1, 2)
		}
		return offsets[self.currentAnim.position]
	elseif self.currentAnim == self.walkRightAnim then
		local offsets = {
			Vector(0, 0),
			Vector(1, 2),
			Vector(0, 0),
			Vector(1, 2)
		}
		return offsets[self.currentAnim.position]
	elseif self.currentAnim == self.jumpPrepareRightAnim or
		self.currentAnim == self.jumpPrepareLeftAnim then
		return Vector(0, 4)
	elseif self.currentAnim == self.jumpLeftAnim then
		return Vector(-2, -2)
	elseif self.currentAnim == self.jumpRightAnim then
		return Vector(2, -2)
	elseif self.currentAnim == self.fallRightAnim then
		return Vector(1, 0)
	elseif self.currentAnim == self.fallLeftAnim then
		return Vector(-1, 0)
	end
	return Vector(0, 0)
end

function PlayerMech:warpOut()

end

function PlayerMech:draw()
	local x,y = self.position:unpack()

	if self.active then
		love.graphics.setColor(255, 255, 255)
	else
		love.graphics.setColor(100, 100, 180, 0)
	end

	if self.invisible then
		love.graphics.setColor(255, 255, 255, 0)
	end

	self.currentAnim:draw(self.spriteSheet, x, y, 0, 1, 1, 64, 64)

	if not self.locked then
		local armoffset = self:getArmOffset()
		local sx = 1
		if self.facingLeft then
			sx = -1
		end
		love.graphics.draw(
			self.armSpriteSheet, 
			self.armForwardQuad, 
			x+armoffset.x, 
			y+armoffset.y, 
			0, 
			sx, 
			1, 
			64+5, 
			64+8
		)
	end
end

return PlayerMech