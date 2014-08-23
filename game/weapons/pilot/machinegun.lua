Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
PlayerBasicBullet = require "game.projectiles.playerbullet"
Particle = require "game.fx.particle"

MachineGun = Class {
	init = function(self, player)
		self.player = player
		self.fireCounter = 0
		self.fireRate = 0.15
		self.shotSound = love.audio.newSource("data/sfx/weapons/pilot_machinegun.wav", "static")
	end
}

function MachineGun:update(dt)
	self.fireCounter = self.fireCounter + dt
end

function MachineGun:fire()
	if self.fireCounter > self.fireRate then
		self.fireCounter = 0
		love.audio.rewind(self.shotSound)
		love.audio.play(self.shotSound)

		local px, py = self.player.position:unpack()
		local offset = self.player:getFireOffset()
		local bulletVelocity = self.player.aimDirection:normalized() * 540

		-- if the player is currently moving, add their velocity to that of the bullet
		bulletVelocity = bulletVelocity + self.player.velocity

		bulletVelocity.x = bulletVelocity.x + math.random(-20, 20)
		bulletVelocity.y = bulletVelocity.y + math.random(-20, 20)

		local bullet = PlayerBasicBullet(
			self.player, 
			px + offset.x + self.player.aimDirection:normalized().x * 4, 
			py + offset.y + self.player.aimDirection:normalized().y * 4, 
			bulletVelocity.x, 
			bulletVelocity.y
		)
		self.player.manager:addEntity(bullet)
	end
end

return MachineGun