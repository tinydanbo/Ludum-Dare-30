Camera = require "lib.hump.camera"
Manager = require "framework.manager"
Player = require "game.player"

local game = {}

function game:enter(oldState)
	self.manager = Manager()
	self.player = Player(32, 32)
	self.manager:addEntity(self.player)
	self.manager:loadMap("test")

	local cx, cy = self.player.position:unpack()
	self.camera = Camera(cx, cy)
	self.camera:zoom(3, 3)
end

function game:update(dt)
	self.manager:update(dt)

	local px, py = self.player.position:unpack()
	self.camera:lookAt(px, py)
end

function game:draw()
	self.camera:attach()
		self.manager:draw()
	self.camera:detach()
end

return game