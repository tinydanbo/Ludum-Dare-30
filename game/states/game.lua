Camera = require "lib.hump.camera"
Vector = require "lib.hump.vector"
Timer = require "lib.hump.timer"
Manager = require "framework.manager"
Player = require "game.player"
PlayerMech = require "game.playermech"
PopcornEnemy = require "game.enemies.popcorn"
BallEnemy = require "game.enemies.ball"

local game = {}

function game:enter(oldState)
	self.manager = Manager()
	self.playermech = PlayerMech(512, 0)
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
	self.cameraSpeed = 400
	self.camera:zoomTo(scaleFactor)

	local gameState = self
	--[[
	Timer.addPeriodic(0.15, function()
		local popcorn = PopcornEnemy(-500, math.random(-256, 256))
		self.manager:addEntity(popcorn)
	end)
	]]--
	Timer.addPeriodic(1, function()
		local ball = BallEnemy(1024, math.random(-128, 128), math.random(-30, -20))
		self.manager:addEntity(ball)
	end)
end

function game:update(dt)
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

	self.manager:update(dt)
	Timer.update(dt)
end

function game:screenShake(magnitude, origin)
	if origin then
		local cx, cy = self.camera:pos()
		local distance = Vector(cx, cy) - origin
		if origin:len() < 128 then
			magnitude = magnitude * (origin:len() / 128)
		end
	end

	if magnitude > 0.1 then
		local randomVector = Vector(math.random(-10, 10), math.random(-10, 10))
		local shakeVector = randomVector:normalized() * magnitude
		self.camera:move(shakeVector.x, shakeVector.y)
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

function game:getActivePlayer()
	if self.player.active then
		return self.player
	else
		return self.playermech
	end
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