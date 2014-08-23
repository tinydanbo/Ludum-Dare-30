Class = require "lib.hump.class"
STI = require "lib.sti"
Vector = require "lib.hump.vector"
HC = require "lib.hardoncollider" -- haha lol lmao

Manager = Class {
	init = function(self)
		self.entities = {}
		self.solids = {}
		local man = self
		self.collider = HC(100, function(dt, shape_a, shape_b, mtv_x, mtv_y)
			man:onCollision(dt, shape_a, shape_b, mtv_x, mtv_y)
		end, function()

		end)
	end
}

function Manager:onCollision(dt, shape_a, shape_b, mtv_x, mtv_y)
	if shape_a.entity.type == "player" then
		if mtv_y < 0 then
			shape_a.entity:onGrounded()
		end
		shape_a.entity:move(Vector(mtv_x, mtv_y))
	elseif shape_a.entity.type == "playerbullet" then
		self.collider:remove(shape_a)
		shape_a.entity:destroy()
	end
end

function Manager:addEntity(entity)
	entity.manager = self
	entity:registerCollisionData(self.collider)
	table.insert(self.entities, entity)
end

function Manager:loadMap(filename)
	self.map = STI.new("data/maps/" .. filename)

	local solidsLayer = self.map.layers["Solids"]
	for _, object in ipairs(solidsLayer.objects) do
		local solid = {
			type = "solid",
			l = solidsLayer.x + object.x,
			t = solidsLayer.y + object.y,
			w = object.width,
			h = object.height
		}
		local solidCollide = self.collider:addRectangle(solid.l, solid.t, solid.w, solid.h)
		solidCollide.entity = {
			type = "solid"
		}
		self.collider:setPassive(solidCollide)
		table.insert(self.solids, solid)
	end
end

function Manager:update(dt)
	local i = 1
	local entityTable = self.entities
	while i <= #entityTable do
		entityTable[i]:update(dt)
		if entityTable[i].isDestroyed then
			table.remove(self.entities, i)
		else
			i = i + 1
		end
	end

	self.collider:update(dt)
end

function Manager:draw()
	love.graphics.setColor(60, 60, 60)
	for _, object in ipairs(self.solids) do
		love.graphics.rectangle("fill", object.l, object.t, object.w, object.h)
	end

	love.graphics.setColor(255, 255, 255)
	for _, object in ipairs(self.entities) do
		object:draw()
	end

	if false then
		love.graphics.setColor(255, 255, 255)
		for object in self.collider:activeShapes() do
			object:draw()
		end
	end
end

return Manager