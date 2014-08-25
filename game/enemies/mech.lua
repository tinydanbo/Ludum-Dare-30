Class = require "lib.hump.class"
Gamestate = require "lib.hump.gamestate"
Vector = require "lib.hump.vector"
Timer = require "lib.hump.timer"
Anim8 = require "lib.anim8"
Entity = require "framework.entity"
EnemyBasicBulletTwo = require "game.projectiles.enemybullet2"

MechEnemy = Class{__includes = Entity,
	init = function(self, x, y, dx)
		Entity.init(self, x, y)
		self.type = "enemy"
		self.solidToPlayer = true
		self.draworder = 5
		self.health = 60
		self.gravity = 200
		self.solid = true
		self.flashDamage = 0
		self.timer = Timer.new()
		self.dx = dx
		self.spriteGrid = Anim8.newGrid(
			128, 128,
			self.spriteSheet:getWidth(), self.spriteSheet:getHeight()
		)
		self.spriteSheet:setFilter("nearest", "nearest")

		self.walkRightAnim = Anim8.newAnimation(self.spriteGrid(
			1, 1,
			3, 1,
			1, 1,
			2, 1
		), 0.2)

		self.currentAnim = self.walkRightAnim

	end,
	spriteSheet = love.graphics.newImage("data/graphics/enemy_mechs.png")
}

function MechEnemy:onHitBy(entity)
	if entity.type == "playerbullet" then
		self.health = self.health - entity.damage
		self.flashDamage = 2
	elseif entity.type == "playermech" then
		local mechspeed = math.abs(entity.dx) + math.abs(entity.dy)
		if mechspeed > 600 then
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

function MechEnemy:explode()
	local explosion = Explosion(
		self.position.x+math.random(-8, 8),
		self.position.y+math.random(-8, 8),
		math.random(30, 40)
	)
	self.manager:addParticle(explosion)
	for i=1,20,1 do
		local scrap = ScrapMetal(
			self.position.x+math.random(-4, 4),
			self.position.y+math.random(-4, 4),
			math.random(3, 5)
		)
		self.manager:addEntity(scrap)
	end
	Gamestate.current().score = Gamestate.current().score + 10000
	Gamestate.current():screenShake(20, self.position)
	self:destroy()
end

function MechEnemy:onPilotKicked(pilot)
	-- think i give a fuck
	self.flashDamage = 10
	self.health = self.health - 10

	if self.health <= 0 then
		self:explode()
	end

	return true
end

function MechEnemy:update(dt)
	self.timer:update(dt)
	self:move(Vector(self.dx * dt, self.gravity * dt))
	self.currentAnim:update(dt)
end

function MechEnemy:registerCollisionData(collider)
	local x,y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-8, y-16, 16, 32)
	self.hitbox.entity = self
end

function MechEnemy:draw()
	local x,y = self.position:unpack()

	if self.flashDamage > 0 then
		love.graphics.setColor(255, 0, 0, 255)
		self.flashDamage = self.flashDamage - 1
	else
		love.graphics.setColor(255, 255, 255, 255)
	end

	self.currentAnim:draw(self.spriteSheet, x, y, 0, 1, 1, 64, 64)
end

return MechEnemy