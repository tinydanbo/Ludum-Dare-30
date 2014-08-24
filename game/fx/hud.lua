Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Entity = require "framework.entity"

Hud = Class {__includes = Entity,
	init = function(self, game)
		self.game = game
		self.font:setFilter("nearest", "nearest")
	end,
	font = love.graphics.newFont("data/font/04B_03__.TTF", 8)
}

function Hud:update(dt)

end

function Hud:draw()
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle("fill", 0, 0, 240, 11)

	love.graphics.setFont(self.font)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("HP" .. tostring(self.game.player.health), 2, 2)
end

return Hud