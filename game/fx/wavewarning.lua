Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Entity = require "framework.entity"
Gamestate = require "lib.hump.gamestate"

WaveWarning = Class {__includes = Entity,
	init = function(self, x, y, waveNo)
		Entity.init(self, x, y)
		self.spriteGrid = Anim8.newGrid(
			240, 16,
			self.spriteSheet:getWidth(), self.spriteSheet:getHeight()
		)
		self.spriteSheet:setFilter("nearest", "nearest")

		if waveNo == 5 and not Gamestate.current().hardmode then
			waveNo = 10
		end
		
		self.animation = Anim8.newAnimation(self.spriteGrid(
			1, 1, 2, 1, 3, 1, 4, 1, 5, 1, 6, 1, 7, 1, 8, 1,
			1, 1+(waveNo), 2, 1+(waveNo), 3, 1+(waveNo), 4, 1+(waveNo),
			3, 1+(waveNo), 2, 1+waveNo, 
			1, 1+(waveNo), 2, 1+(waveNo), 3, 1+(waveNo), 4, 1+(waveNo),
			3, 1+(waveNo), 2, 1+waveNo, 
			1, 1+(waveNo), 2, 1+(waveNo), 3, 1+(waveNo), 4, 1+(waveNo),
			3, 1+(waveNo), 2, 1+waveNo, 
			1, 1+waveNo,
			8, 1, 7, 1, 6, 1, 5, 1, 4, 1, 3, 1, 2, 1, 1, 1
		), 0.05, function()
			self:destroy()
		end)
	end,
	spriteSheet = love.graphics.newImage("data/graphics/hud_wavesignal.png")
}

function WaveWarning:update(dt)
	self.animation:update(dt)
end

function WaveWarning:draw()
	local cx,cy = Gamestate.current().camera:pos()
	love.graphics.setColor(255, 255, 255, 255)
	self.animation:draw(self.spriteSheet, cx, cy, 0, 1, 1, 120, 8)
end

return WaveWarning