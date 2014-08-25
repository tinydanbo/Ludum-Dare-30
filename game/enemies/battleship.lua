Class = require "lib.hump.class"
Gamestate = require "lib.hump.gamestate"
Vector = require "lib.hump.vector"
Timer = require "lib.hump.timer"
Anim8 = require "lib.anim8"
Entity = require "framework.entity"
EnemyBasicBulletTwo = require "game.projectiles.enemybullet2"

BattleshipEnemy = Class{__includes = Entity,
	init = function(self, x, y, dx)
		Entity.init(self, x, y)
		self.type = "enemy"
		self.solidToPlayer = true
		self.draworder = 5
		self.health = 50
		self.flashDamage = 2
		self.timer = Timer.new()
		self.dx = dx
		self.spriteGrid = Anim8.newGrid(
			128, 128,
			self.spriteSheet:getWidth(), self.spriteSheet:getHeight()
		)
		self.spriteSheet:setFilter("nearest", "nearest")

		self.flyLeftAnim = Anim8.newAnimation(self.spriteGrid(
			1, 1,
			2, 1,
			3, 1,
			2, 1
		), 0.2)

		self.currentAnim = self.flyLeftAnim
		self.timer:addPeriodic(0.1, function()
			self:fireBullet()
		end)
	end,
	spriteSheet = love.graphics.newImage("data/graphics/enemy_ship.png")
}

function BattleshipEnemy:fireBullet()
	local bullet = EnemyBasicBulletTwo(
		self,
		self.position.x + math.random(-5, 5),
		self.position.y,
		math.random(-40, 40),
		math.random(100, 160)
	)
	self.manager:addEntity(bullet)
end

function BattleshipEnemy:onHitBy(entity)
	if entity.type == "playerbullet" then
		self.health = self.health - entity.damage
		self.flashDamage = 2
	elseif entity.type == "playermech" then
		local mechspeed = math.abs(entity.dx) + math.abs(entity.dy)
		if mechspeed > 500 then
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

function BattleshipEnemy:explode()
	local explosion = Explosion(
		self.position.x+math.random(-8, 8),
		self.position.y+math.random(-8, 8),
		math.random(30, 40)
	)
	self.manager:addParticle(explosion)
	for i=1,30,1 do
		local scrap = ScrapMetal(
			self.position.x+math.random(-4, 4),
			self.position.y+math.random(-4, 4),
			math.random(3, 5)
		)
		self.manager:addEntity(scrap)
	end
	Gamestate.current():screenShake(20, self.position)
	self:destroy()
end

function BattleshipEnemy:onPilotKicked(pilot)
	-- think i give a fuck
end

function BattleshipEnemy:update(dt)
	self.timer:update(dt)
	self:move(Vector(self.dx * dt), 0)
	self.currentAnim:update(dt)
end

function BattleshipEnemy:fireAtPlayer()

end

function BattleshipEnemy:registerCollisionData(collider)
	local x,y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-25, y-2, 50, 8)
	self.hitbox.entity = self
end

function BattleshipEnemy:draw()
	local x,y = self.position:unpack()

	if self.flashDamage > 0 then
		love.graphics.setColor(255, 0, 0, 255)
		self.flashDamage = self.flashDamage - 1
	else
		love.graphics.setColor(255, 255, 255, 255)
	end

	self.currentAnim:draw(self.spriteSheet, x, y, self.rotation, 1, 1, 64, 64)
end

return BattleshipEnemy