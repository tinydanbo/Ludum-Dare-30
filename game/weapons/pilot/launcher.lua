Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Gamestate = require "lib.hump.gamestate"
PlayerSword = require "game.projectiles.playersword"
Particle = require "game.fx.particle"
Sparkle = require "game.fx.sparkle"

Launcher = Class {
	init = function(self, player)
		self.player = player
		self.fireCounter = 0
		self.fireRate = 0.5
		self.shotSound = love.audio.newSource("data/sfx/weapons/pilot_shotgun.wav", "static")
	end
}

function Launcher:update(dt)
	self.fireCounter = self.fireCounter + dt
end

function Launcher:fire()
	if self.fireCounter > self.fireRate then
		self.fireCounter = 0
		love.audio.rewind(self.shotSound)
		love.audio.play(self.shotSound)

		-- Gamestate.current():screenShake(15)

		local px,py = self.player.position:unpack()
		local offset = self.player:getFireOffset()

		local bulletVelocity = self.player.aimDirection * 80

		bulletVelocity.x = bulletVelocity.x + math.random(-10, 10)
		bulletVelocity.y = bulletVelocity.y + math.random(-10, 10)

		if self.player.aimDirection == Vector(0, 0) then
			if self.player.facingLeft then
				bulletVelocity = Vector(-1, 0) * 80
			else
				bulletVelocity = Vector(1, 0) * 80
			end
		elseif self.player.aimDirection.y == 0 then
			bulletVelocity.y = -40
			bulletVelocity.x = bulletVelocity.x * 2
		elseif self.player.aimDirection.x == 0 then
			bulletVelocity.y = bulletVelocity.y * 2
		end

		bulletVelocity = bulletVelocity + self.player.velocity

		local bullet = PlayerSword(
			self.player,
			px + offset.x + self.player.aimDirection.x * 8,
			py + offset.y + self.player.aimDirection.y * 8,
			bulletVelocity.x,
			bulletVelocity.y
		)
		bullet.gravity = 300
		bullet.draworder = 5
		self.player.manager:addEntity(bullet)
	end
end

return Launcher