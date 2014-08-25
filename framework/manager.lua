Class = require "lib.hump.class"
STI = require "lib.sti"
Vector = require "lib.hump.vector"
HC = require "lib.hardoncollider" -- haha lol lmao

Manager = Class {
	init = function(self)
		self.entities = {}
		self.solids = {}
		self.count = 0
		local man = self
		self.collider = HC(100, function(dt, shape_a, shape_b, mtv_x, mtv_y)
			man:onCollision(dt, shape_a, shape_b, mtv_x, mtv_y)
		end, function()

		end)
	end
}

function Manager:onCollision(dt, shape_a, shape_b, mtv_x, mtv_y)
	if shape_a.entity.type == "player" and shape_b.entity.type == "solid" then
		if mtv_y < 0 then
			shape_a.entity:onGrounded()
		end
		shape_a.entity:move(Vector(mtv_x, mtv_y))
	elseif shape_a.entity.type == "playermech" and shape_b.entity.type == "solid" then
		if mtv_y < 0 then
			shape_a.entity:onGrounded()
		end
		shape_a.entity:move(Vector(mtv_x, mtv_y))
	elseif shape_a.entity.type == "playerbullet" and shape_b.entity.type == "solid" then
		-- self.collider:remove(shape_a)
		-- shape_a.entity:destroy()
	elseif shape_a.entity.type == "playerbullet" and shape_b.entity.type == "enemy" then
		shape_b.entity:onHitBy(shape_a.entity)
		if not shape_b.entity.burning then
			shape_a.entity:onHit()
		end
	elseif shape_a.entity.type == "enemy" and shape_b.entity.type == "playerbullet" then
		shape_a.entity:onHitBy(shape_b.entity)
		if not shape_a.entity.burning then
			shape_b.entity:onHit()
		end
	elseif shape_a.entity.type == "playermech" and shape_b.entity.type == "enemy" then
		shape_b.entity:move(Vector(-mtv_x, -mtv_y))
		shape_b.entity:onHitBy(shape_a.entity)
	elseif shape_a.entity.type == "enemy" and shape_b.entity.type == "playermech" then
		shape_a.entity:move(Vector(mtv_x, mtv_y))
		shape_a.entity:onHitBy(shape_b.entity)
	elseif shape_a.entity.type == "item" and shape_b.entity.type == "solid" then
		shape_a.entity:move(Vector(mtv_x, mtv_y))
		if mtv_y < 0 then
			shape_a.entity:freeze()
		end
	elseif shape_a.entity.type == "item" and shape_b.entity.type == "player" then
		shape_b.entity:onCollect(shape_a.entity)
		shape_a.entity:destroy()
	elseif shape_a.entity.type == "player" and shape_b.entity.type == "item" then
		shape_a.entity:onCollect(shape_b.entity)
		shape_b.entity:destroy()
	elseif shape_a.entity.type == "player" and shape_b.entity.type == "enemybullet" then
		shape_b.entity:destroy()
		shape_a.entity:onHitBy(shape_b.entity)
	elseif shape_a.entity.type == "enemybullet" and shape_b.entity.type == "player" then
		shape_a.entity:destroy()
		shape_b.entity:onHitBy(shape_a.entity)
	elseif shape_a.entity.type == "enemybullet" and shape_b.entity.type == "solid" then
		shape_a.entity:destroy()
	elseif shape_a.entity.type == "player" and shape_b.entity.type == "enemy" then
		if shape_a.entity.locked then
			shape_b.entity:onPilotKicked(shape_a.entity)
			shape_a.entity:kickRecoil()
		end
	elseif shape_a.entity.type == "enemy" and shape_b.entity.type == "player" then
		if shape_b.entity.locked then
			shape_a.entity:onPilotKicked(shape_b.entity)
			shape_b.entity:kickRecoil()
		end
	end
end

function Manager:addEntity(entity)
	self.count = self.count + 1
	entity.manager = self

	if not entity.draworder then
		entity.draworder = 3
	end
	
	entity:registerCollisionData(self.collider)
	table.insert(self.entities, entity)
end

function Manager:addParticle(particle)
	self.count = self.count + 1
	particle.manager = self
	if not particle.draworder then
		particle.draworder = 5
	end
	table.insert(self.entities, particle)
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
			self.count = self.count - 1
		else
			i = i + 1
		end
	end

	self.collider:update(dt)
end

function Manager:draw()

	self.map:drawLayer(self.map.layers["World"])

	love.graphics.setColor(255, 255, 255)
	for i=1,5,1 do
		for _, object in ipairs(self.entities) do
			if object.draworder == i then
				object:draw()
			end
		end
	end

	if false then
		love.graphics.setColor(255, 255, 255)
		for object in self.collider:activeShapes() do
			object:draw()
		end
	end
end

return Manager