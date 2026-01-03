require 'class'

class 'Animation'

function Animation:init(texture, mapping, frames, scale)
	self.mapping = mapping
	self.frames = frames
	self.rect = Rectangle(texture, 0, 0)
	self.scale = scale
	self.x = 0
	self.y = 0
end

function Animation:setFrameCycle(name)
	self.cycle = name
	self.framecounter = 1
	self.currentFrame = self.frames[name][self.framecounter]
end

function Animation:setNextFrame()
	local cycle = self.frames[self.cycle]
	self.framecounter = self.framecounter + 1
	if cycle[self.framecounter] == nil then self.framecounter = 1 end
	self.currentFrame = cycle[self.framecounter]
end

function Animation:setPosition(x, y)
	self.x = x
	self.y = y
end

function Animation:start()
	self.stop = false
	app.renderList:add(self.rect)

	function animate()
		local animation = self

		while animation.stop == false do
			local frame = self.mapping[self.currentFrame]
			local width = frame[3]
			local height = frame[4]
			animation.rect:setSource(frame)
			animation.rect:setDest { self.x, self.y, width * animation.scale, height * animation.scale }
			app.renderList:shouldRender(true)
			animation:setNextFrame()
			wait(100)
		end

		app.renderList:remove(animation.rect)
	end

	addTask(animate)
end
