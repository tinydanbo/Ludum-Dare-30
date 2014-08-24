Class = require "lib.hump.class"
Gamestate = require "lib.hump.gamestate"
Vector = require "lib.hump.vector"
Timer = require "lib.hump.timer"
Anim8 = require "lib.anim8"
Entity = require "framework.entity"

BallEnemy = Class{__includes = Entity,
	init = function(self, x, y, dx)
		Entity.init(self, x, y)
		self.type = "enemy"
		self.speed = 80
		self.originaly = y
		self.draworder = 5
		self.elapsed = 0
		self.state = "patrol"
		self.health = 30
		self.flashDamage = 0
		self.rotation = 0
		self.timer = Timer.new()
		self.rotationSpeed = 10
		self.dx = dx
		self.spriteGrid = Anim8.newGrid(
			64, 64,
			self.spriteSheet:getWidth(), self.spriteSheet:getHeight()
		)
		self.spriteSheet:setFilter("nearest", "nearest")

		self.patrolLeftAnim = Anim8.newAnimation(self.spriteGrid(
			1, 1,
			2, 1,
			3, 1,
			2, 1
		), 0.5)

		self.watchingLeftAnim = Anim8.newAnimation(self.spriteGrid(
			3, 1,
			2, 1
		), 0.2)

		self.attackingLeftAnim = Anim8.newAnimation(self.spriteGrid(
			4, 1,
			3, 1
		), 0.05)

		self.currentAnim = self.patrolLeftAnim
	end,
	spriteSheet = love.graphics.newImage("data/graphics/enemy_ball.png")
}

function BallEnemy:onHitBy(entity)
	if entity.type == "playerbullet" then
		self.health = self.health - entity.damage
		self.flashDamage = 2
		local olddx = self.dx
	elseif entity.type == "playermech" then
		local mechspeed = math.abs(entity.dx) + math.abs(entity.dy)
		if mechspeed > 300 then
			self:move(Vector(math.random(-16, 16), math.random(-16, 16)))
			self.health = 0
			entity.dx = entity.dx * 0.8
			entity.dy = entity.dy * 0.8
		end
	end

	if self.health <= 0 then
		self:explode()
	end
end

function BallEnemy:explode()
	local explosion = Explosion(
		self.position.x+math.random(-8, 8),
		self.position.y+math.random(-8, 8),
		math.random(16, 24)
	)
	self.manager:addParticle(explosion)
	for i=1,5,1 do
		local scrap = ScrapMetal(
			self.position.x+math.random(-4, 4),
			self.position.y+math.random(-4, 4),
			math.random(4, 5)
		)
		self.manager:addEntity(scrap)
	end
	Gamestate.current():screenShake(10, self.position)
	self:destroy()
end

function BallEnemy:update(dt)
	self.timer:update(dt)
	self.elapsed = self.elapsed + dt
	local target = Gamestate.current():getActivePlayer()
	local x,y = self.position:unpack()

	if self.state == "patrol" then
		self.desiredy = self.originaly + math.sin(math.rad(self.elapsed*90)) * 8
		self:move(Vector(self.dx * dt, self.desiredy - self.position.y))

		local difference = target.position - self.position
		if difference:len() < 80 then
			self.state = "watch"
			self.currentAnim = self.watchingLeftAnim
			self.timer:addPeriodic(0.8, function()
				self.timer:add(0.1, function()
					self:fireAtPlayer()
				end)
				self.timer:add(0.2, function()
					self:fireAtPlayer()
				end)
				self.timer:add(0.3, function()
					self:fireAtPlayer()
				end)
			end)
		end
	elseif self.state == "watch" then
		self.desiredy = self.originaly + math.sin(math.rad(self.elapsed*90)) * 8
		self:move(Vector(0, self.desiredy - self.position.y))

		local difference = target.position - self.position
		local aimAt = difference:normalized()

		local desiredRotation = math.atan2(-aimAt.x, aimAt.y) - math.rad(30)
		local rotationDiff = desiredRotation - self.rotation

		if math.abs(rotationDiff) < (self.rotationSpeed * dt) then
			self.rotation = desiredRotation
		elseif rotationDiff < 0 then
			self.rotation = self.rotation - (self.rotationSpeed * dt)
		elseif rotationDiff > 0 then
			self.rotation = self.rotation + (self.rotationSpeed * dt)
		end
	end
	self.currentAnim:update(dt)
end

function BallEnemy:fireAtPlayer()
	print("ey")
end

function BallEnemy:registerCollisionData(collider)
	local x,y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-8, y-8, 16, 16)
	self.hitbox.entity = self
end

function BallEnemy:draw()
	local x,y = self.position:unpack()

	if self.flashDamage > 0 then
		love.graphics.setColor(255, 0, 0, 255)
		self.flashDamage = self.flashDamage - 1
	else
		love.graphics.setColor(255, 255, 255, 255)
	end
	self.currentAnim:draw(self.spriteSheet, x, y, self.rotation, 1, 1, 32, 32)
end

return BallEnemy