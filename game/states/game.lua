Camera = require "lib.hump.camera"
Vector = require "lib.hump.vector"
Manager = require "framework.manager"
Player = require "game.player"
PlayerMech = require "game.playermech"

local game = {}

function game:enter(oldState)
	self.manager = Manager()
	self.playermech = PlayerMech(192, 0)
	self.manager:addEntity(self.playermech)
	self.player = Player(192, 0)
	self.manager:addEntity(self.player)

	self.playermech.player = self.player
	self.player.draworder = 2
	self.player.mech = self.playermech
	self.player.draworder = 4

	self.manager:loadMap("test")

	local cx, cy = self.player.position:unpack()
	self.camera = Camera(cx, cy)
	self.desiredCameraPosition = Vector(cx, cy)
	self.cameraSpeed = 600
	self.camera:zoomTo(scaleFactor)
end

function game:update(dt)
	self.manager:update(dt)

	if self.player.active then
		self.desiredCameraPosition = self.player:getDesiredCameraPosition()
	elseif self.playermech.active then
		self.desiredCameraPosition = self.playermech:getDesiredCameraPosition()
	end

	local cx, cy = self.camera:pos()
	local cameraDifference = Vector(cx - self.desiredCameraPosition.x, cy - self.desiredCameraPosition.y)
	if cameraDifference:len() < (self.cameraSpeed * dt) then
		self.camera:lookAt(self.desiredCameraPosition.x, self.desiredCameraPosition.y)
	else
		local cameraMove = cameraDifference:normalized() * (self.cameraSpeed * dt)
		self.camera:move(-cameraMove.x, -cameraMove.y)
	end
end

function game:handleRescale(scaleFactor)
	self.camera:zoomTo(scaleFactor)
end

function game:draw()
	love.graphics.setColor(100, 150, 200)
	love.graphics.rectangle("fill", 0, 0, love.window.getWidth(), love.window.getHeight())
	self.camera:attach()
		self.manager:draw()
	self.camera:detach()
end

function game:keyreleased(key, code)
	if key == "k" or key == "x" then
		self.player.active = not self.player.active
		self.playermech.active = not self.playermech.active
		if self.player.active then
			self.player.draworder = 4
			self.playermech.draworder = 2
		else
			self.player.draworder = 2
			self.playermech.draworder = 4
		end
	end

	if self.playermech.active then
		self.playermech:keyreleased(key, code)
	end
end

function game:keypressed(key, code)
	if self.player.active then
		self.player:keypressed(key, code)
	end
end

return game