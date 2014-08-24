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
		self.draworder = 5
		self.elapsed = 0
		self.health = 10
		self.flashDamage = 0
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
end

function BallEnemy:update(dt)
	self.elapsed = self.elapsed + dt
	local target = Gamestate.current():getActivePlayer()
	local x,y = self.position:unpack()

	self:move(Vector(self.dx * dt, math.sin(math.rad(self.elapsed*180))))
	self.patrolLeftAnim:update(dt)
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
	self.patrolLeftAnim:draw(self.spriteSheet, x, y, 0, 1, 1, 32, 32)
end

return BallEnemy