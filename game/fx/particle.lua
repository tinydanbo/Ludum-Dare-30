Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Entity = require "framework.entity"

Particle = Class {__includes = Entity,
	init = function(self, style, x, y, dx, dy, size, r, g, b, a, decay)
		Entity.init(self, x, y)
		self.style = style
		self.velocity = Vector(dx, dy)
		self.size = size
		self.r = r
		self.g = g
		self.b = b
		self.a = a
		self.decay = decay
	end
}

function Particle:update(dt)
	self.position = self.position + (self.velocity * dt)
	self.a = self.a - (self.decay * dt)

	if self.a < 0 or self.size < 0 then
		self:destroy()
	end
end

function Particle:draw()
	local x, y = self.position:unpack()

	love.graphics.setColor(self.r, self.g, self.b, self.a)
	if self.style == "circle" then
		love.graphics.circle("fill", x, y, self.size)
	elseif self.style == "square" then
		love.graphics.rectangle("fill", x-self.size, y-self.size, self.size*2, self.size*2)
	end
end

return Particle