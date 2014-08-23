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

		if self.player.facingLeft then
			local bullet = PlayerBasicBullet(self.player, px-12, py+3, -360, math.random(-20, 20))
			local muzzleFlash = Particle("circle", px-12, py+3, 0, 0, 4, 255, 200, 0, 255, 1000)
			self.player.manager:addEntity(bullet)
			self.player.manager:addEntity(muzzleFlash)
		else
			local bullet = PlayerBasicBullet(self.player, px+12, py+3, 360, math.random(-20, 20))
			local muzzleFlash = Particle("circle", px+12, py+3, 0, 0, 4, 255, 200, 0, 255, 1000)
			self.player.manager:addEntity(bullet)
			self.player.manager:addEntity(muzzleFlash)
		end

		if self.player.facingLeft then
			self.player:move(Vector(2, -1))
		else
			self.player:move(Vector(-2, -1))
		end
	end
end

return MachineGun