Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Entity = require "framework.entity"

Player = Class{__includes = Entity,
	init = function(self, x, y)
		Entity.init(self, x, y)
		self.type = "player"
		self.movespeed = 150
		self.gravity = 10
		self.dy = 0
		self.grounded = false
	end
}

function Player:update(dt)
	local desiredDirection = Vector(0, 0)
	if love.keyboard.isDown("a", "left") then
		desiredDirection.x = -1
	elseif love.keyboard.isDown("d", "right") then
		desiredDirection.x = 1
	end

	if love.keyboard.isDown(" ") and self.grounded then
		self.dy = -280
		self.grounded = false
	end

	local movement = desiredDirection * (self.movespeed * dt)
	self:move(movement)

	self.dy = self.dy + self.gravity
	self:move(Vector(0, (self.dy * dt)))
end

function Player:onGrounded()
	self.dy = 0
	self.grounded = true
end

function Player:registerCollisionData(collider)
	local x,y = self.position:unpack()

	self.hitbox = collider:addRectangle(x-4, y-4, 8, 10)
	self.hitbox.entity = self
end

function Player:draw()
	local x,y = self.position:unpack()

	love.graphics.setColor(200, 50, 200)
	love.graphics.circle("fill", x, y, 8)
end

return Player