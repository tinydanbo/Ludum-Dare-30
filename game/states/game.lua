Camera = require "lib.hump.camera"
Vector = require "lib.hump.vector"
Manager = require "framework.manager"
Player = require "game.player"

local game = {}

function game:enter(oldState)
	self.manager = Manager()
	self.player = Player(32, 32)
	self.manager:addEntity(self.player)
	self.manager:loadMap("test")

	local cx, cy = self.player.position:unpack()
	self.camera = Camera(cx, cy)
	self.desiredCameraPosition = Vector(cx, cy)
	self.cameraSpeed = 500
	self.camera:zoom(2, 2)
end

function game:update(dt)
	self.manager:update(dt)

	self.desiredCameraPosition = self.player:getDesiredCameraPosition()

	local cx, cy = self.camera:pos()
	local cameraDifference = Vector(cx - self.desiredCameraPosition.x, cy - self.desiredCameraPosition.y)
	if cameraDifference:len() < (self.cameraSpeed * dt) then
		self.camera:lookAt(self.desiredCameraPosition.x, self.desiredCameraPosition.y)
	else
		local cameraMove = cameraDifference:normalized() * (self.cameraSpeed * dt)
		self.camera:move(-cameraMove.x, -cameraMove.y)
	end
end

function game:draw()
	self.camera:attach()
		self.manager:draw()
	self.camera:detach()
end

return game