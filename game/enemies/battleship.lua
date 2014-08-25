Class = require "lib.hump.class"
Gamestate = require "lib.hump.gamestate"
Vector = require "lib.hump.vector"
Timer = require "lib.hump.timer"
Anim8 = require "lib.anim8"
Entity = require "framework.entity"
EnemyBasicBullet = require "game.projectiles.enemybullet"

BattleshipEnemy = Class{__includes = Entity,
	init = function(self, x, y, dx)
		Entity.init(self, x, y)
		self.type = "enemy"
		self.solidToPlayer = true
		self.draworder = 5
		self.health = 50
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
	end,
	spriteSheet = love.graphics.newImage("data/graphics/enemy_ship.png")
}

function BattleshipEnemy:onHitBy(entity)

end

function BattleshipEnemy:explode()

end

function BattleshipEnemy:onPilotKicked(pilot)
	-- think i give a fuck
end

function BattleshipEnemy:update(dt)
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

	self.currentAnim:draw(self.spriteSheet, x, y, self.rotation, 1, 1, 64, 64)
end

return BattleshipEnemy