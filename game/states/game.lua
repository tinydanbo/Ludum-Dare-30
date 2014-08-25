Camera = require "lib.hump.camera"
Vector = require "lib.hump.vector"
Timer = require "lib.hump.timer"
Manager = require "framework.manager"
Player = require "game.player"
PlayerMech = require "game.playermech"
Anim8 = require "lib.anim8"
PopcornEnemy = require "game.enemies.popcorn"
BallEnemy = require "game.enemies.ball"
Hud = require "game.fx.hud"
MechWarp = require "game.fx.mechwarp"
Battleship = require "game.enemies.battleship"
thanksState = require "game.states.thanks"
bonusState = require "game.states.bonus"
WaveWarning = require "game.fx.wavewarning"

local game = {}

function game:enter(oldState)
	self.manager = Manager()
	self.playermech = PlayerMech(512, 256)
	self.manager:addEntity(self.playermech)
	self.player = Player(32, 256)
	self.manager:addEntity(self.player)
	self.slowmo = false
	self.skipFrame = false
	self.paused = false
	self.backgroundmaskalpha = 0

	self.playermech.player = self.player
	self.player.draworder = 2
	self.player.mech = self.playermech
	self.player.draworder = 4
	self.score = 0

	self.hud = Hud(self)

	self.manager:loadMap("flat")

	local cx, cy = self.player.position:unpack()
	self.camera = Camera(cx, cy)
	self.desiredCameraPosition = Vector(cx, cy)
	self.cameraSpeed = 400
	self.camera:zoomTo(scaleFactor)

	self.backgroundSky = love.graphics.newImage("data/graphics/Background SKY.png")
	self.backgroundSky:setFilter("nearest", "nearest")

	self.backgroundFar = love.graphics.newImage("data/graphics/Background 2ndary.png")
	self.backgroundFar:setFilter("nearest", "nearest")

	self.backgroundNear = love.graphics.newImage("data/graphics/Background Animation2.png")
	self.backgroundNear:setFilter("nearest", "nearest")

	self.backgroundNearGrid = Anim8.newGrid(240, 160,
		self.backgroundNear:getWidth(), self.backgroundNear:getHeight()
	)

	self.pauseScreen = love.graphics.newImage("data/graphics/screen_pause.png")
	self.pauseScreen:setFilter("nearest", "nearest")

	self.backgroundNearAnimation = Anim8.newAnimation(
		self.backgroundNearGrid(
			1, 1,
			2, 1,
			3, 1,
			2, 1
		), 0.5
	)

	local gameState = self

	self.waveReadyToFinish = true
	self.waveNo = 0

	self.music = love.audio.newSource("data/music/Qygen - Moron Lobe.ogg", "stream")
	self.music:setLooping(true)
	self.music:play()

	self.mechaMusic = love.audio.newSource("data/music/Qygen - Moron Lobe (Mecha Theme).ogg", "stream")
	self.mechaMusic:setVolume(0)
	self.mechaMusic:setLooping(true)
	self.mechaMusic:play()

	self.clearSound = love.audio.newSource("data/sfx/gameclear.wav", "static")

	--[[
	Timer.addPeriodic(0.15, function()
		local popcorn = PopcornEnemy(
			self.player.position.x+128, 
			self.player.position.y+math.random(-128, 128)
		)
		self.manager:addEntity(popcorn)
	end)
	]]--
	--[[
	Timer.addPeriodic(2, function()
		local target = self.player
		if self.playermech.active then
			target = self.playermech
		end
		local ball = BallEnemy(
			target.position.x+128, 
			target.position.y+math.random(-24, 0), 
			math.random(-150, -100)
		)
		self.manager:addEntity(ball)
	end)
	Timer.addPeriodic(5, function()
		local ship = Battleship(
			self.player.position.x+512,
			80,
			-100
		)
		self.manager:addEntity(ship)
	end)
	]]--
end

function game:onPlayerDeath()
	self.slowmo = true
	Timer.add(1, function()
		love.audio.stop()
		love.audio.rewind()
		Gamestate.switch(thanksState)
	end)
end

function game:advanceWave()
	if self.waveNo == 5 then
		self.waveReadyToFinish = false
		-- game clear!!!!!
		self.slowmo = true
		love.audio.stop()
		self.clearSound:rewind()
		self.clearSound:play()
		Timer.add(2, function()
			Gamestate.switch(bonusState)
		end)
	else
		self.waveNo = self.waveNo + 1
		self.waveReadyToFinish = false
		Timer.add(0.5, function()
			local waveWarning = WaveWarning(
				0,
				0,
				self.waveNo
			)
			waveWarning.draworder = 5
			self.manager:addEntity(waveWarning)
		end)
		Timer.add(1, function()
			self:startWave(self.waveNo)
		end)
	end
end

function game:spawnBallEnemy(difficulty)
	local target = self.player
	if self.playermech.active then
		target = self.playermech
	end
	local ball = BallEnemy(
		2000, 
		target.position.y+math.random(-24, 0), 
		math.random(-150, -100)
	)
	if math.random(0, 10) > 5 then
		ball = BallEnemy(
			-100, 
			target.position.y+math.random(-24, 0), 
			math.random(100, 150)
		)
	end
	self.manager:addEntity(ball)
end

function game:spawnPopcorn(difficulty)
	for i=0,difficulty,1 do
		local target = self.player
		if self.playermech.active then
			target = self.playermech
		end
		local xoffset = math.random(200, 300)
		if math.random(0, 10) > 5 then
			xoffset = xoffset * -1
		end
		local popcorn = PopcornEnemy(
			target.position.x+xoffset, 
			target.position.y+math.random(-256, 16)
		)

		self.manager:addEntity(popcorn)
	end
end

function game:startWave(waveNo)
	if waveNo == 1 then
		Timer.add(1, function()
			self:spawnPopcorn(3)
		end)
		Timer.add(2, function()
			self:spawnPopcorn(5)
		end)
		Timer.add(3, function()
			self:spawnPopcorn(7)
		end)
		Timer.add(4, function()
			self:spawnPopcorn(10)
		end)
		Timer.add(5, function()
			self:spawnPopcorn(10)
			self.waveReadyToFinish = true
		end)
		Timer.add(30, function()
			if self.waveNo == waveNo then
				self.manager:destroyAllEnemies()
			end
		end)
	end
	--[[
	Timer.add(0.1, function()
		self:spawnBallEnemy(1)
	end)
	Timer.add(5, function()
		self:spawnBallEnemy(1)
	end)
	Timer.add(10, function()
		self:spawnBallEnemy(1)
	end)
	Timer.add(10.1, function()
		self.waveReadyToFinish = true
	end)
	Timer.add(15, function()
		if self.waveNo == waveNo then
			self.manager:destroyAllEnemies()
		end
	end)
	]]--
end

function game:update(dt)
	if self.paused then
		return
	end

	if self.waveReadyToFinish and self.manager:countEnemies() == 0 then
		self:advanceWave()
	end
	print(self.manager:countEnemies())

	if self.slowmo then
		if self.skipFrame then
			self.skipFrame = false
			return
		else
			self.skipFrame = true
		end
		self.backgroundmaskalpha = self.backgroundmaskalpha + (1000 * dt)
		if self.backgroundmaskalpha > 255 then
			self.backgroundmaskalpha = 255
		end
	end

	self.backgroundNearAnimation:update(dt)

	if self.playermech.active and self.playermech.scrappower == 0 then
		self.player.active = not self.player.active
		self.playermech.active = not self.playermech.active
		self.mechaMusic:setVolume(0)
		self.music:setVolume(1)
		local mechwarpeffect = MechWarp(
			self.playermech.position.x,
			self.playermech.position.y-8
		)
		self.manager:addParticle(mechwarpeffect)
		local desiredPlayerPosition = Vector(self.playermech.position.x, self.player.position.y)
		self.player:move(desiredPlayerPosition - self.player.position)
		self.playermech:warpOut()
		self.player.draworder = 4
		self.playermech.draworder = 2
	end

	if self.player.active then
		self.desiredCameraPosition = self.player:getDesiredCameraPosition()
	elseif self.playermech.active then
		self.desiredCameraPosition = self.playermech:getDesiredCameraPosition()
	end

	local cx, cy = self.camera:pos()
	local cameraDifference = Vector(cx - self.desiredCameraPosition.x, cy - self.desiredCameraPosition.y)
	if cameraDifference:len() < (self.cameraSpeed * dt) then
		self.camera:lookAt(
			math.floor(self.desiredCameraPosition.x), 
			math.floor(self.desiredCameraPosition.y)
		)
	else
		local cameraMove = cameraDifference:normalized() * (self.cameraSpeed * dt)
		self.camera:move(
			math.floor(-cameraMove.x), 
			math.floor(-cameraMove.y)
		)
	end

	self.manager:update(dt)
	self.hud:update(dt)
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

function game:drawBackground()
	local cx, cy = self.camera:pos()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(self.backgroundSky, 0, 0)

	local farOffset = (cy-300) * -0.05
	if farOffset < -30 then
		farOffset = -30
	end
	love.graphics.draw(self.backgroundFar, 0, farOffset)

	local nearOffset = (cy-250) * -0.2
	if nearOffset < -15 then
		nearOffset = -15
	end
	self.backgroundNearAnimation:draw(self.backgroundNear, 0, nearOffset)
end

function game:draw()

	love.graphics.push()
		love.graphics.scale(scaleFactor, scaleFactor)
		love.graphics.setColor(255, 255, 255, 255)
		self:drawBackground()
		love.graphics.setColor(255, 255, 255, self.backgroundmaskalpha)
		love.graphics.rectangle("fill", 0, 0, 240, 160)
	love.graphics.pop()

	self.camera:attach()
		self.manager:draw()
	self.camera:detach()

	love.graphics.push()
		love.graphics.scale(scaleFactor, scaleFactor)
		love.graphics.setColor(255, 255, 255, 255)
		self.hud:draw()
		if self.paused then
			love.graphics.draw(self.pauseScreen, 0, 0)
		end
	love.graphics.pop()
end

function game:getActivePlayer()
	if self.player.active then
		return self.player
	else
		return self.playermech
	end
end

function game:keyreleased(key, code)
	if key == "v" or key == ";" then
		if self.player.active and self.player.scrap >= 180 then
			self.player.active = not self.player.active
			self.playermech.active = not self.playermech.active
			self.mechaMusic:setVolume(1)
			self.music:setVolume(0)
			local desiredMechPosition = Vector(self.player.position.x, self.player.position.y)
			self.playermech:move(desiredMechPosition - self.playermech.position)
			self.player:warpOut()
			self.playermech:warpIn()
			self.playermech.scrappower = self.player.scrap
			self.player.scrap = 0
			Timer.add(0.5, function() 
				local mechwarpeffect = MechWarp(
					self.playermech.position.x,
					self.playermech.position.y-8
				)
				self.manager:addParticle(mechwarpeffect)
			end)
			self.player.draworder = 2
			self.playermech.draworder = 4
		end
	end

	if key == "escape" then
		self.paused = not self.paused
	end

	if self.playermech.active then
		self.playermech:keyreleased(key, code)
	else
		self.player:keyreleased(key, code)
	end
end

function game:keypressed(key, code)
	if self.player.active then
		self.player:keypressed(key, code)
	end
end

return game