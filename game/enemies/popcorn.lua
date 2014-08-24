Class = require "lib.hump.class"
Gamestate = require "lib.hump.gamestate"
Vector = require "lib.hump.vector"
Anim8 = require "lib.anim8"
Entity = require "framework.entity"
Explosion = require "game.fx.explosion"
Particle = require "game.fx.particle"

PopcornEnemy = Class{__includes = Entity,
	init = function(self, x, y)
		Entity.init(self, x, y)
		self.type = "enemy"
		self.speed = 100
		self.health = 1
		self.rotation = 0
		self.burning = false
		self.burningfuel = 255
		self.burningdx = 0
		self.burningdy = 0
		self.burnrate = math.random(300, 600)
		self.spriteGrid = Anim8.newGrid(
			64, 64,
			self.spriteSheet:getWidth(), self.spriteSheet:getHeight()
		)
		self.spriteSheet:setFilter("nearest", "nearest")

		self.flyingAnim = Anim8.newAnimation(self.spriteGrid(
			1, 1,
			2, 1,
			3, 1,
			4, 1,
			5, 1
		), 0.1)

	end,
	spriteSheet = love.graphics.newImage("data/graphics/enemy_popcorn.png")
}

function PopcornEnemy:update(dt)
	local target = Gamestate.current():getActivePlayer()
	local x,y = self.position:unpack()

	if self.burning then
		local smoke = Particle(
			"circle",
			x+math.random(-4, 4),
			y+math.random(-4, 4),
			math.random(-4, 4),
			math.random(-4, 4),
			math.random(1, 3),
			100+math.random(0, 60),
			100+math.random(0, 40),
			100,
			200,
			math.random(250, 300)
		)
		self.manager:addParticle(smoke)
		self.burningfuel = self.burningfuel - (self.burnrate * dt)
		if self.burningfuel < 0 then
			self:explode()
		end
		self.burningdy = self.burningdy + 10
		self:move(Vector(self.burningdx, self.burningdy) * dt)
	else
		local diff = target.position - self.position
		self:move(diff:normalized() * (self.speed * dt))
	end
	self.flyingAnim:update(dt)
end

function PopcornEnemy:onHitBy(entity)
	if not self.burning then
		if entity.type == "playerbullet" then
			self.health = self.health - entity.damage
		elseif entity.type == "playermech" then
			local mechspeed = math.abs(entity.dx) + math.abs(entity.dy)
			if mechspeed > 200 then
				self:move(Vector(math.random(-16, 16), math.random(-16, 16)))
				self.health = 0
				entity.dx = entity.dx * 0.99
				entity.dy = entity.dy * 0.99
			end
		end

		if self.health <= 0 then
			self:onDeath()
		end
	end
end

function PopcornEnemy:explode()
	local explosion = Explosion(
		self.position.x+math.random(-8, 8),
		self.position.y+math.random(-8, 8),
		math.random(16, 24)
	)
	self.manager:addParticle(explosion)
	Gamestate.current():screenShake(5, self.position)
	self:destroy()
end

function PopcornEnemy:onDeath()
	local roll = math.random(1, 10)
	if roll < 8 then
		self:explode()
	else
		self.burning = true
		self.burningdx = math.random(-200, 200)
		self.burningdy = math.random(-50, -100)
	end
end

function PopcornEnemy:registerCollisionData(collider)
	local x,y  = self.position:unpack()

	self.hitbox = collider:addRectangle(x-10, y-10, 20, 20)
	self.hitbox.entity = self
end

function PopcornEnemy:draw()
	local x,y  = self.position:unpack()

	love.graphics.setColor(self.burningfuel, self.burningfuel, self.burningfuel)
	self.flyingAnim:draw(self.spriteSheet, x, y, 0, 1, 1, 32, 32)
end

return PopcornEnemy