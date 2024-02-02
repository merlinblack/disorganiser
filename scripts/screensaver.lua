require 'gui/screen'
require 'clock'
require 'suspend'

class 'ScreenSaver' (Screen)

function ScreenSaver:build()
	Screen.build(self)
	self.font = Font('media/mono.ttf', 48)
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
	self.renderList:clear()
	self.renderList:shouldRender()
	yield()
	self.renderList:shouldRender()

	local width = app.width
	local height = app.height

	if app.isPictureFrame then
		local color = Color '000'
		local rectangle <close> = Rectangle(color, true, {0,0,app.width,app.height})
		self.renderList:add(rectangle)
	else
		height = height - clockHeight
	end

	print('Setting',filename)
	local texture <close> = Texture(filename)
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

	local rectangle = Rectangle(texture, dest, src)

	self.renderList:add(rectangle)

	if not app.isPictureFrame then
		local texture <close> = Texture(self.font, weather.temperature .. '°', Color('bbb'))
		local yjitter = math.random(5, app.height - 25 - texture.height)
		local rectangle = Rectangle(texture, {app.width - texture.width - 25, yjitter, 0, 0})
		self.renderList:add(rectangle)


		self.renderList:add(clockRenderList)
	else
		self:nightTimeDim()
	end
end

function ScreenSaver:nightTimeDim()
	local time = tonumber(os.date('%H%M'))

	if time < 800 or time > 2230 then
		print('Dimming: ', time)
		local dimming = Rectangle(Color('A0000000'), true, { 0, 0, app.width, app.height })
		self.renderList:add(dimming)
	end
end

function ScreenSaver:mouseClick(time, x, y, button)
	self.previousScreen:activate()
end

function ScreenSaver:activate()
	if self:isActive() then
		print( 'Screen Already activated: ', self.__type)
		return
	end
	print('Activating Screen: ', self.__type)
	if self.previousScreen == nil then
		self.previousScreen = setCurrentScreen(self)
	else
		setCurrentScreen(self)
	end
	app.renderList = self.renderList
	self.renderList:shouldRender()
end

function ScreenSaver:deactivate()
	Screen.deactivate(self)
	self.stop = true
	wakeTask('screensaver')
end

function ScreenSaver:swipe()
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
			screenSaver.pictureIter = dirList(screenSaver.directory .. '*.jpg')
			picture = screenSaver.pictureIter()
		end

		screenSaver:setPicture(picture)
		wait(screenSaver.time or 30000)
	end
	clockJitter = false
end

function startScreenSave()
	if app.isPictureFrame then
		screenSaver:setDirectory('media/picture-frame/')
	else
		screenSaver:setDirectory('media/family/')
	end
	addUniqueTask(screenSaveTask, 'screensaver')
end

function checkForScreenSaveNeeded()
	while true do
		if caffine ~= true and getCurrentScreen() ~= screenSaver and getCurrentScreen() ~= suspend then
			if lastEvent + 10*60000 < app.ticks then
				startScreenSave()
			end
		end
		wait(1000)
	end
end

addTask(checkForScreenSaveNeeded, 'screen saver check')
