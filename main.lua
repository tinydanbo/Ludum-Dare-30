io.stdout:setvbuf("no")

StateManager = require "lib.hump.gamestate"
gameState = require "game.states.game" -- haha lol

local scaleFactor = 3

function love.load()
	love.window.setMode(240*scaleFactor, 160*scaleFactor)
	love.graphics.setDefaultFilter("nearest", "nearest")
	StateManager.registerEvents({'update'})
	StateManager.switch(gameState)
end

function love.draw()
	-- love.graphics.push()
		-- love.graphics.scale(scaleFactor, scaleFactor)
		StateManager.draw()
	-- love.graphics.pop()

	love.graphics.setColor(255, 255, 255)
	love.graphics.print(tostring(love.timer.getFPS( )), 10, 10)
end