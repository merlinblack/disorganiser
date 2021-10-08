require 'gui/screen'
require 'clock'

class 'ScreenSaver' (Screen)

function ScreenSaver:build()
	Screen.build(self)

	self:setPicture('1.jpg')
end

function ScreenSaver:setPicture(filename)
	print('Setting',filename)
	self.renderList:clear()
	local texture <close> = app.renderer:textureFromFile('media/' .. filename)
	local src = { 0, 0, texture.width, texture.height}
	local dest = { 0, 0, 800, 480}
	local rectangle = Rectangle(texture, dest, src);
	self.renderList:add(rectangle)
	self.renderList:add(clockRenderList)
end

function ScreenSaver:mouseClick(time, x, y, button)
	mainScreen:activate()
end

function ScreenSaver:deactivate()
	self.stop = true
	print('deactivating screen saver')
	wakeTask('screensaver')
end

screenSaver = ScreenSaver()

function screenSaveTask()
	screenSaver:activate()

	n = 1
	screenSaver.stop = false
	while not screenSaver.stop do
		screenSaver:setPicture(n .. '.jpg')
		n = n + 1
		if n > 6 then
			n = 1
		end
		wait(30000)
	end
end
