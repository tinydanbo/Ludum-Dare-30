Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Entity = require "framework.entity"

Explosion = Class {__includes = Entity,
	init = function(self, x, y, size)
		Entity.init(self, x, y)
		self.size = size
		self.frame = 0
		self.alpha = 255
		self.decay = 1000

		local sound = self.sounds[1]
		sound:rewind()
		sound:play()
	end,
	sounds = {
		love.audio.newSource("data/sfx/explosion_1.wav", "static")
	}
}

function Explosion:update(dt)
	self.alpha = self.alpha - (self.decay * dt)
	if self.alpha < 0 then
		self:destroy()
	end
end

function Explosion:draw()
	if self.frame < 5 then
		love.graphics.setColor(0, 0, 0, 255)
		self.frame = self.frame + 1
	else
		love.graphics.setColor(255, 255, 255, self.alpha)
	end
	love.graphics.circle("fill", self.position.x, self.position.y, self.size, 16)
end

return Explosion