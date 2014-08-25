Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Entity = require "framework.entity"

HurtBox = Class {__includes = Entity,
	init = function(self, player, x, y, width, height, damage, lifetime)
		Entity.init(self, x, y)
		self.type = "playerbullet"
		self.player = player
		self.firstFrame = true
		self.lived = 0
		self.width = width
		self.height = height
		self.lifetime = lifetime
		self.damage = damage
	end
}

function HurtBox:registerCollisionData(collider)
	local x,y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-self.width/2, y-self.height/2, self.width, self.height)
	self.hitbox.entity = self
end

function HurtBox:onHit()

end

function HurtBox:update(dt)
	if self.velocity then
		print("hi")
		self:move(self.velocity * dt)
	end

	self.lived = self.lived + dt
	if self.lived > self.lifetime then
		self:destroy()
	end
end

function HurtBox:draw()

end

return HurtBox