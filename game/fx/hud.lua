Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
Entity = require "framework.entity"

Hud = Class {__includes = Entity,
	init = function(self, game)
		self.game = game
		self.font:setFilter("nearest", "nearest")
		self.icons:setFilter("nearest", "nearest")
		self.hp:setFilter("nearest", "nearest")
		self.ammo:setFilter("nearest", "nearest")
		self.scoreFont:setFilter("nearest", "nearest")
		self.whiteFont:setFilter("nearest", "nearest")
		self.healthIconQuad = love.graphics.newQuad(
			0, 0,
			11, 11,
			self.icons:getWidth(), self.icons:getHeight()
		)
		self.healthPipQuad = love.graphics.newQuad(
			0, 0,
			8, 7,
			self.hp:getWidth(), self.hp:getHeight()
		)
		self.bulletIconQuad = love.graphics.newQuad(
			22, 0,
			11, 11,
			self.icons:getWidth(), self.icons:getHeight()
		)
		self.ammoPipQuad = love.graphics.newQuad(
			0, 0,
			2, 5,
			self.ammo:getWidth(), self.ammo:getHeight()
		)
		self.scoreIconQuad = love.graphics.newQuad(
			11, 0,
			11, 11,
			self.icons:getWidth(), self.icons:getHeight()
		)
	end,
	font = love.graphics.newFont("data/font/04B_03__.TTF", 8),
	icons = love.graphics.newImage("data/graphics/hud_icons.png"),
	hp = love.graphics.newImage("data/graphics/hud_hp.png"),
	ammo = love.graphics.newImage("data/graphics/hud_ammo1.png"),
	scoreFont = love.graphics.newImageFont("data/graphics/hud_font_Score.png", "1234567890"),
	whiteFont = love.graphics.newImageFont("data/graphics/hud_font_white.png", "1234567890")
}

function Hud:update(dt)

end

function Hud:draw()
	local hudy = 160-15
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle("fill", 0, hudy, 240, 15)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(self.icons, self.healthIconQuad, 4, hudy+2)

	local playerHealth = self.game.player.health
	local i = 0
	while playerHealth >= 20 do
		playerHealth = playerHealth - 20
		love.graphics.draw(self.hp, self.healthPipQuad, 18+(9*i), hudy+2+2)
		i = i + 1
	end
	love.graphics.draw(self.hp, self.healthPipQuad, 18+(9*i), hudy+2+2, 0, playerHealth/20, 1, 0, 0)

	love.graphics.draw(self.icons, self.bulletIconQuad, 88, hudy+2)

	for i=0,16,1 do
		love.graphics.draw(self.ammo, self.ammoPipQuad, 102+(3*i), hudy+2+2)
	end

	love.graphics.draw(self.icons, self.scoreIconQuad, 160, hudy+2)

	love.graphics.setFont(self.scoreFont)
	love.graphics.print("1234567", 174, hudy+4)

	if self.game.player.active then
		love.graphics.setFont(self.whiteFont)
		love.graphics.printf(tostring(self.game.player.scrap), 0, 8, 240, "center")
	end
end

return Hud