io.stdout:setvbuf("no")

StateManager = require "lib.hump.gamestate"
gameState = require "game.states.game" -- haha lol

scaleFactor = 1

function love.load()
	love.window.setMode(240*scaleFactor, 160*scaleFactor)
	love.graphics.setDefaultFilter("nearest", "nearest")
	StateManager.registerEvents({'update', 'keypressed'})
	StateManager.switch(gameState)
end

function love.draw()
	StateManager.draw()

	love.graphics.setColor(255, 255, 255)
	love.graphics.print(tostring(love.timer.getFPS( )), 10, 10)
end

function love.keyreleased(key, code)
	if key == "1" or key == "2" or key == "3" or key == "4" or key == "5" then
		scaleFactor = tonumber(key)
		StateManager.current():handleRescale(scaleFactor)
		love.window.setMode(240*scaleFactor, 160*scaleFactor)
	end
	StateManager.keyreleased(key, code)
end