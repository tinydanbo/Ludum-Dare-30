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
		self.shotSound = love.audio.newSource("data/sfx/weapons/vulcan.wav", "static")
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
		local offset = self.mech:getFireOffset():rotated(self.mech.armrotation)

		self.currentFireOffset = self.currentFireOffset + 1
		if self.currentFireOffset > #self.fireOffsets then
			self.currentFireOffset = 1
		end

		local bulletVelocity = Vector(math.cos(self.mech.armrotation), math.sin(self.mech.armrotation)) * 300

		if self.mech.facingLeft then
			bulletVelocity.x = bulletVelocity.x * -1
			bulletVelocity.y = bulletVelocity.y * -1
		end

		bulletVelocity.x = bulletVelocity.x + math.random(-40, 40) + self.mech.dx
		bulletVelocity.y = bulletVelocity.y + math.random(-40, 40)

		local bullet = PlayerVulcanBullet(
			self.player, 
			x+offset.x, 
			y+offset.y, 
			bulletVelocity.x, 
			bulletVelocity.y
		)
		self.mech.manager:addEntity(bullet)

		local originalOffset = self.mech:getFireOffset()
		local shellCasing = Particle(
			"square",
			x + (originalOffset.x / 2) + math.random(-4, 4),
			y + originalOffset.y,
			bulletVelocity.x * -0.1,
			math.random(-150, -100),
			1,
			255,
			228,
			54,
			225,
			0,
			0
		)
		shellCasing.ddy = math.random(400, 600)
		shellCasing.lifedecay = 0.5
		-- self.mech.manager:addParticle(shellCasing)
	end
end

return VulcanCannon