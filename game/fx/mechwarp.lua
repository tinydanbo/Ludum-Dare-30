Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Anim8 = require "lib.anim8"
Entity = require "framework.entity"
Sparkle = require "game.fx.sparkle"

MechWarp = Class {__includes = Entity,
	init = function(self, x, y)
		Entity.init(self, x, y)
		self.sparklecounter = 0
		self.sparklerate = 0.05
		self.spriteGrid = Anim8.newGrid(
			64, 64,
			self.spriteSheet:getWidth(), self.spriteSheet:getHeight()
		)
		self.spriteSheet:setFilter("nearest", "nearest")

		self.animation = Anim8.newAnimation(self.spriteGrid(
			1, 1,
			2, 1,
			3, 1,
			4, 1,
			5, 1,
			6, 1,
			7, 1,
			1, 2,
			2, 2,
			3, 2,
			4, 2,
			5, 2,
			6, 2,
			7, 2
		), 0.075, function()
			self:destroy()
		end)

	end,
	spriteSheet = love.graphics.newImage("data/graphics/Mech Explosion Redo.png"),
}

function MechWarp:update(dt)
	self.animation:update(dt)
	self.sparklecounter = self.sparklecounter + dt
	if self.sparklecounter > self.sparklerate then
		self.sparklecounter = 0
		local randomVector = Vector(math.random(-50, 50), math.random(-50, 50)):normalized()
		local sparkle = Sparkle(
			self.position.x + randomVector.x * 32,
			self.position.y + randomVector.y * 32,
			randomVector.x * 64,
			randomVector.y * 64
		)
		self.manager:addParticle(sparkle)
	end
end

function MechWarp:draw()
	local x,y  = self.position:unpack()
	love.graphics.setColor(255, 255, 255, 255)
	self.animation:draw(self.spriteSheet, x, y, 0, 2, 2, 32, 32)
end

return MechWarp