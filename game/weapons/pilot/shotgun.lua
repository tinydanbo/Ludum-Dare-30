Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Gamestate = require "lib.hump.gamestate"
PlayerShotgunBullet = require "game.projectiles.playershotgunbullet"
Particle = require "game.fx.particle"
Sparkle = require "game.fx.sparkle"

Shotgun = Class {
	init = function(self, player)
		self.player = player
		self.fireCounter = 0
		self.fireRate = 0.2
		self.shotSound = love.audio.newSource("data/sfx/weapons/pilot_shotgun.wav", "static")
	end
}

function Shotgun:update(dt)
	self.fireCounter = self.fireCounter + dt
end

function Shotgun:fire()
	if self.fireCounter > self.fireRate then
		self.fireCounter = 0
		love.audio.rewind(self.shotSound)
		love.audio.play(self.shotSound)

		-- Gamestate.current():screenShake(15)

		local px,py = self.player.position:unpack()
		local offset = self.player:getFireOffset()

		for angleoffset = -0.5,0.5,0.1 do
			local spreadAimAt = self.player.aimDirection:rotated(angleoffset)
			local bulletVelocity = spreadAimAt * 340

			bulletVelocity = bulletVelocity + self.player.velocity
			bulletVelocity.x = bulletVelocity.x + math.random(-40, 40)
			bulletVelocity.y = bulletVelocity.y + math.random(-40, 40)

			local bullet = PlayerShotgunBullet(
				self.player,
				px + offset.x,
				py + offset.y,
				bulletVelocity.x,
				bulletVelocity.y,
				math.random(2,3)
			)
			self.player.manager:addEntity(bullet)
		end

		for i=0,4,1 do
			-- its a ref! haha
			local gunsmoke = Particle(
				"circle",
				px+offset.x,
				py+offset.y,
				self.player.aimDirection.x * math.random(20,30) + self.player.velocity.x,
				self.player.aimDirection.y * math.random(20,30) + math.random(-20, 20) + self.player.velocity.y,
				math.random(2, 3),
				150,
				150,
				150,
				200,
				100,
				1
			)
			gunsmoke.draworder = 1
			self.player.manager:addParticle(gunsmoke)
		end

		local sparkle = Sparkle(
			px+offset.x+math.random(-4, 4),
			py+offset.y+math.random(-4, 4),
			self.player.aimDirection.x * math.random(20,30) + self.player.velocity.x,
			self.player.aimDirection.y * math.random(20,30) + math.random(-20, 20) + self.player.velocity.y
		)
		sparkle.draworder = 5
		self.player.manager:addParticle(sparkle)
	end
end

return Shotgun