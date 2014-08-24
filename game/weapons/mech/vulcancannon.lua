Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Gamestate = require "lib.hump.gamestate"
PlayerVulcanBullet = require "game.projectiles.playervulcanbullet"
Particle = require "game.fx.particle"

VulcanCannon = Class {
	init = function(self, mech)
		self.mech = mech
		self.fireCounter = 0
		self.fireRate = 0.05
		self.fireOffsets = {
			Vector(0, 0),
			Vector(0, 2),
			Vector(0, 4),
			Vector(0, 2),
			Vector(0, 0),
			Vector(0, -2),
			Vector(0, -4),
			Vector(0, -2)
		}
		self.currentFireOffset = 1
		self.shotSound = love.audio.newSource("data/sfx/weapons/pilot_machinegun.wav", "static")
	end
}

function VulcanCannon:update(dt)
	self.fireCounter = self.fireCounter + dt
end

function VulcanCannon:fire()
	if self.fireCounter > self.fireRate then
		self.fireCounter = 0
		love.audio.rewind(self.shotSound)
		love.audio.play(self.shotSound)

		x, y = self.mech.position:unpack()
		local offset = self.mech:getFireOffset()
		offset = offset + self.fireOffsets[self.currentFireOffset]

		self.currentFireOffset = self.currentFireOffset + 1
		if self.currentFireOffset > #self.fireOffsets then
			self.currentFireOffset = 1
		end

		local bulletVelocity = Vector(0, math.random(-10, 10))

		if self.mech.facingLeft then
			bulletVelocity.x = -300
		else
			bulletVelocity.x = 300
		end

		bulletVelocity.x = bulletVelocity.x + math.random(-20, 20) + self.mech.dx
		bulletVelocity.y = bulletVelocity.y + math.random(-20, 20)

		local bullet = PlayerVulcanBullet(
			self.player, 
			x + offset.x, 
			y + offset.y, 
			bulletVelocity.x, 
			bulletVelocity.y
		)
		self.mech.manager:addEntity(bullet)
	end
end

return VulcanCannon