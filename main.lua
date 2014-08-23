io.stdout:setvbuf("no")

StateManager = require "lib.hump.gamestate"
gameState = require "game.states.game" -- haha lol

local scaleFactor = 2

function love.load()
	love.window.setMode(240*scaleFactor, 160*scaleFactor)
	love.graphics.setDefaultFilter("nearest", "nearest")
	StateManager.registerEvents({'update'})
	StateManager.switch(gameState)
end

function love.draw()
	StateManager.draw()

	love.graphics.setColor(255, 255, 255)
	love.graphics.print(tostring(love.timer.getFPS( )), 10, 10)
end