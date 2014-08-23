Class = require "lib.hump.class"
Vector = require "lib.hump.vector"

Entity = Class {
	init = function(self, x, y)
		self.position = Vector(x, y)
	end,
	isDestroyed = false
}

function Entity:move(v)
	self.position = self.position + v

	-- TODO : move collision
	if self.hitbox then
		self.hitbox:move(v)
	end
end

function Entity:registerCollisionData(collider)

end

function Entity:draw()

end

function Entity:destroy()
	self.isDestroyed = true
end

return Entity