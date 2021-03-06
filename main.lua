io.stdout:setvbuf("no")

StateManager = require "lib.hump.gamestate"
titleState = require "game.states.title" -- haha lol

scaleFactor = 2

function love.load()
	love.window.setMode(240*scaleFactor, 160*scaleFactor)
	love.graphics.setDefaultFilter("nearest", "nearest")
	StateManager.registerEvents({'update', 'keypressed'})
	StateManager.switch(titleState)
end

function love.draw()
	StateManager.draw()
end

function love.keyreleased(key, code)
	if key == "1" or key == "2" or key == "3" or key == "4" or key == "5" then
		scaleFactor = tonumber(key)
		StateManager.current():handleRescale(scaleFactor)
		love.window.setMode(240*scaleFactor, 160*scaleFactor)
	end
	StateManager.keyreleased(key, code)
end