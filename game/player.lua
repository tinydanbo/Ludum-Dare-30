Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Timer = require "lib.hump.timer"
Gamestate = require "lib.hump.gamestate"
Anim8 = require "lib.anim8"
Entity = require "framework.entity"
Particle = require "game.fx.particle"
MachineGun = require "game.weapons.pilot.machinegun"
Shotgun = require "game.weapons.pilot.shotgun"
Launcher = require "game.weapons.pilot.launcher"
Sparkle = require "game.fx.sparkle"


Player = Class{__includes = Entity,
	init = function(self, x, y)
		Entity.init(self, x, y)
		self.type = "player"
		self.active = true
		self.movespeed = 150
		self.gravity = 10
		self.scrap = 0
		self.dy = 0
		self.dx = 0
		self.locked = false
		self.kickcharge = 100
		self.health = 120
		self.maxhealth = 120
		self.grounded = false
		self.firing = false
		self.facingLeft = false
		self.invuln = false
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

		self.jumpRightAimUpAnim = Anim8.newAnimation(self.spriteGrid2(
			4, 1
		), 0.1)
		self.jumpLeftAimUpAnim = self.jumpRightAimUpAnim:clone():flipH()

		self.kickRightAnim = Anim8.newAnimation(self.spriteGrid2(
			5, 1
		), 0.1)
		self.kickLeftAnim = self.kickRightAnim:clone():flipH()

		self.hurtRightAnim = Anim8.newAnimation(self.spriteGrid(
			5, 2
		), 0.1)
		self.hurtLeftAnim = self.hurtRightAnim:clone():flipH()

		self.currentAnim = self.standRightAnim
	end,
	spriteSheet = love.graphics.newImage("data/graphics/player_pilot.png"),
	spriteSheet2 = love.graphics.newImage("data/graphics/player_pilot_2.png"),
	whiteShader = love.graphics.newShader("data/shaders/white.fs"),
	powerupSound = love.audio.newSource("data/sfx/powerup.wav", "static"),
	deadSound = love.audio.newSource("data/sfx/playerdead.wav", "static"),
	jumpSound = love.audio.newSource("data/sfx/pilot_jump.wav", "static"),
	kickSound = love.audio.newSource("data/sfx/dash.wav", "static"),
	bounceSound = love.audio.newSource("data/sfx/bounce.wav", "static")
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
	return Vector(self.position.x, self.position.y-24)
end

function Player:onHitBy(projectile)
	local oldhealth = self.health
	local breakpoint = 0
	while oldhealth > 20 do
		breakpoint = breakpoint + 20
		oldhealth = oldhealth - 20
	end

	self.health = self.health - projectile.damage

	if self.health < 0 then
		self.health = 0
		self.locked = true
		if self.facingLeft then
			self.currentAnim = self.hurtLeftAnim
			self.dx = 100
		else
			self.currentAnim = self.hurtRightAnim
			self.dx = -100
		end
		self.dy = -100
		love.audio.stop()
		self.deadSound:rewind()
		self.deadSound:play()
		Gamestate.current():onPlayerDeath()
	elseif self.health < breakpoint then
		self.health = breakpoint
		-- stagger
		self.locked = true
		self.invuln = true
		if self.facingLeft then
			self.currentAnim = self.hurtLeftAnim
			self.dx = 100
		else
			self.currentAnim = self.hurtRightAnim
			self.dx = -100
		end
		self.dy = -100
		
		Timer.add(0.5, function()
			self.invuln = false
		end)
		Timer.add(1, function()
			self.locked = false
		end)
	else
		self.invuln = true
		Timer.add(0.08*projectile.damage, function()
			self.invuln = false
		end)
	end
end

function Player:update(dt)
	self.weapon:update(dt)
	if self.active and not self.locked then
		self:updateAimDirection()
	end
	self:checkIsGrounded()

	self.kickcharge = self.kickcharge + (40 * dt)
	if self.kickcharge > 100 then
		self.kickcharge = 100
	end

	if self.weapon.ammo == 0 then
		self.weapon = MachineGun(self)
	end

	local desiredDirection = Vector(0, 0)
	if self.active and not self.locked then
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

	if love.keyboard.isDown("z", "j") and not self.locked and self.active then
		self.firing = true
		self.weapon:fire()
	else
		self.firing = false
	end

	if not self.grounded and not self.locked then
		if self.facingLeft then
			if self.aimDirection.y == -1 then
				self.currentAnim = self.jumpLeftAimUpAnim
			else
				self.currentAnim = self.jumpLeftAnim
			end
		else
			if self.aimDirection.y == -1 then
				self.currentAnim = self.jumpRightAimUpAnim
			else
				self.currentAnim = self.jumpRightAnim
			end
		end
	end

	if not self.locked then
		local movement = desiredDirection * (self.movespeed * dt)
		self:move(movement)

		self.velocity = desiredDirection * self.movespeed

		self.dy = self.dy + self.gravity
		self:move(Vector(0, (self.dy * dt)))
	else
		local x, y = self.position:unpack()
		for i=1,3,1 do
			local boostsmoke = Particle(
				"circle",
				x+math.random(-4, 4),
				y+math.random(-4, 4),
				math.random(-4, 4),
				math.random(-4, 4),
				math.random(1, 3),
				200,
				200,
				200,
				200,
				200
			)
			boostsmoke.draworder = 1

			if self.grounded then
				boostsmoke.position.y = y+8
			end

			self.manager:addParticle(boostsmoke)
		end

		self.dy = self.dy + ((self.gravity * 100) * dt)
		self:move(Vector(self.dx * dt, self.dy * dt))
	end

	if self.position.y > 1000 then
		local positiondiff = Vector(32, 256) - self.position
		self:move(positiondiff)
	end

	if self.scrap > 999 then
		self.scrap = 999
	end
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
	--[[
	local x,y = self.position:unpack()
	local isGrounded = false

	for _, shape in ipairs(self.manager.collider:shapesAt(x, y+11)) do
		if shape.entity.type == "solid" then
			isGrounded = true
		end
	end

	self.grounded = isGrounded
	]]--
end

function Player:warpOut()
	local x, y = self.position:unpack()
	for i=1,10,1 do
		local sparkle = Sparkle(
			x+math.random(-4, 4),
			y+math.random(-4, 4),
			math.random(-30, 30),
			math.random(-30, 30)
		)
		self.manager:addParticle(sparkle)
	end
end

function Player:onGrounded()
	self.dy = 0
	self.grounded = true
end

function Player:onCollect(item)
	local ix, iy = item.position:unpack()
	local particle = Particle(
		"square",
		ix,
		iy,
		0,
		-10,
		2,
		255,
		255,
		255,
		255,
		1000
	)
	self.manager:addParticle(particle)
	if item.size then
		self.scrap = self.scrap + item.size
		Gamestate.current().score = Gamestate.current().score + item.size*100
	elseif item.itemtype then
		self.powerupSound:rewind()
		self.powerupSound:play()
		if item.itemtype == 1 then
			self.weapon = Shotgun(self)
		elseif item.itemtype == 2 then
			self.weapon = Launcher(self)
		elseif item.itemtype == 3 then
			self.scrap = self.scrap + 50
			self.health = self.health + 10
		end
	end
end

function Player:stopKick()
	if self.locked then
		self.locked = false
		self.gravity = 10
		self.hitbox:rotate(math.rad(-90))
		self.hitbox:scale(0.5)
	end
end

function Player:kickRecoil()
	if self.locked then
		self.dy = -200
		self.dx = self.dx * -0.2
		self.gravity = 10
	end
	self.bounceSound:rewind()
	self.bounceSound:play()
end

function Player:registerCollisionData(collider)
	local x,y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-3, y-4, 6, 14)
	self.hitbox.entity = self
end

function Player:keypressed(key, code)
	if (key == "x" or key == "k" or key == " ") and self.active and self.grounded then
		self.dy = -180
		self.grounded = false
		self.jumpSound:rewind()
		self.jumpSound:play()
	elseif (key == "l" or key == "c") and self.active and not self.locked and self.kickcharge > 50 then
		self.locked = true
		self.gravity = 0
		self.kickSound:rewind()
		self.kickSound:play()
		self.kickcharge = self.kickcharge - 50
		if self.facingLeft then
			self.currentAnim = self.kickLeftAnim
			self.dx = -400
		else
			self.currentAnim = self.kickRightAnim
			self.dx = 400
		end
		if love.keyboard.isDown("up", "w") then
			self.dy = -200
			self.dx = self.dx * 0.5
		elseif love.keyboard.isDown("down", "s") then
			self.dy = 200
			self.dx = self.dx * 0.5
		else
			self.dy = 0
		end
		self.invuln = true
		self.hitbox:rotate(math.rad(90))
		self.hitbox:scale(2)
		Timer.add(0.1, function()
			self.invuln = false
		end)
		Timer.add(0.5, function()
			self:stopKick()
		end)
	end
end

function Player:keyreleased(key, code)

end

function Player:draw()
	local x,y = self.position:unpack()

	if self.active then
		love.graphics.setColor(255, 255, 255)
		if self.invuln then
			love.graphics.setShader(self.whiteShader)
		end
	else
		love.graphics.setColor(180, 100, 100, 0)
	end

	local image = self.spriteSheet

	-- "yikes"
	if self.currentAnim == self.runRightAimUpAnim or
		self.currentAnim == self.runLeftAimUpAnim or 
		self.currentAnim == self.standLeftAimUpAnim or
		self.currentAnim == self.standRightAimUpAnim or
		self.currentAnim == self.runLeftAimDownAnim or
		self.currentAnim == self.runRightAimDownAnim or
		self.currentAnim == self.standRightAimDownAnim or
		self.currentAnim == self.standLeftAimDownAnim or
		self.currentAnim == self.jumpRightAimUpAnim or
		self.currentAnim == self.jumpLeftAimUpAnim or
		self.currentAnim == self.kickLeftAnim or
		self.currentAnim == self.kickRightAnim then
		image = self.spriteSheet2
	end

	if self.locked then
		love.graphics.setColor(0, 0, 200, 100)
		self.currentAnim:draw(image, x+self.dx*-0.04, y+self.dy*-0.04, 0, 1, 1, 32, 32)
		love.graphics.setColor(0, 0, 200, 150)
		self.currentAnim:draw(image, x+self.dx*-0.02, y+self.dy*-0.02, 0, 1, 1, 32, 32)
		love.graphics.setColor(0, 0, 200, 200)
		self.currentAnim:draw(image, x+self.dx*-0.01, y+self.dy*-0.01, 0, 1, 1, 32, 32)
		love.graphics.setColor(255, 255, 255, 255)
	end

	self.currentAnim:draw(image, x, y, 0, 1, 1, 32, 32)

	love.graphics.setShader()
end

return Player