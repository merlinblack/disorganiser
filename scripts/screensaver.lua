require 'gui/screen'
require 'clock'
require 'suspend'

class 'ScreenSaver' (Screen)

function ScreenSaver:build()
	Screen.build(self)
end

function ScreenSaver:setDirectory(directory)
	if self.directory ~= directory then
		self.pictureIter = function() end
		self.directory = directory
	end
end

function ScreenSaver:setTime(secs)
	self.time = secs
end

function ScreenSaver:setPicture(filename)
	local width = 800
	local height = 460
	print('Setting',filename)
	self.renderList:clear()
	self.renderList:shouldRender()
	local texture <close> = app.renderer:textureFromFile(filename)
	local src = { 0, 0, texture.width, texture.height}
	-- Zoom
	local scaleX = width / texture.width
	local scaleY = height / texture.height
	local scale = math.min(scaleX,scaleY)
	local dest = { 0, 0, math.floor(texture.width*scale), math.floor(texture.height*scale)}
	-- Center
	if dest[3] < width then
		dest[1] = width//2 - dest[3]//2
	end
	if dest[4] < height then
		dest[2] = height//2 - dest[4]//2
	end

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

	screenSaver.stop = false
	clockJitter = true
	while not screenSaver.stop do
		picture = screenSaver.pictureIter()
		if not picture then
			screenSaver.pictureIter = dirlist(screenSaver.directory .. '*.jpg')
			picture = screenSaver.pictureIter()
		end

		screenSaver:setPicture(picture)
		wait(screenSaver.time or 30000)
	end
	clockJitter = false
end

function checkForScreenSaveNeeded()
	while true do
		if caffine ~= true and getCurrentScreen() ~= screenSaver and getCurrentScreen() ~= suspend then
			if lastEvent + 10*60000 < app.ticks then
				screenSaver:setDirectory('media/alara/')
				addTask(screenSaveTask, 'screensaver')
			end
		end
		wait(1000)
	end
end

addTask(checkForScreenSaveNeeded, 'screen saver check')
