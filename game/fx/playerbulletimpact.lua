Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Anim8 = require "lib.anim8"
Entity = require "framework.entity"

PlayerBulletImpact = Class {__includes = Entity,
	init = function(self, x, y)
		Entity.init(self, x, y)
		self.spriteGrid = Anim8.newGrid(
			32, 32,
			self.spriteSheet:getWidth(), self.spriteSheet:getHeight()
		)
		self.spriteSheet:setFilter("nearest", "nearest")

		self.animation = Anim8.newAnimation(self.spriteGrid(
			1, 1,
			2, 1,
			3, 1,
			4, 1,
			5, 1,
			6, 1
		), 0.02, function()
			self:destroy()
		end)

		self.sound:rewind()
		self.sound:play()
	end,
	spriteSheet = love.graphics.newImage("data/graphics/Bullet Impact Pilot.png"),
	sound = love.audio.newSource("data/sfx/weapons/small_hit.wav")
}

function PlayerBulletImpact:update(dt)
	self.animation:update(dt)
end

function PlayerBulletImpact:draw()
	local x,y  = self.position:unpack()
	self.animation:draw(self.spriteSheet, x, y, 0, 1, 1, 16, 16)
end

return PlayerBulletImpact