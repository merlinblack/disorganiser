require 'clock'
require 'docker'
require 'weather'
require 'unlock'

require 'gui/screen'
require 'main2'

class 'MainScreen' (Screen)

function MainScreen:build()
	Screen.build(self)

	self.fontCode = Font('media/Aurek-Besh.ttf', 18)

	local texture <close> = app.renderer:textureFromFile('media/vader.jpg')
	local src = { 0, 0, texture.width, texture.height}
	local dest = {0, 0, app.width, app.height}
	local rectangle <close> = Rectangle(texture, dest, src)
	self.renderList:add(rectangle)

	local btn = { 30, 300, 150, 110}
	local textcolor = Color 'f30a4a'
	local backcolor = textcolor:clone()
	backcolor.a = 0x20
	self:addButton(btn, 'Çikiş', function() quit() end, textcolor, nil, backcolor)

	btn[2] = btn[2] - 140
	self:addButton(btn, 'Docker', function() docker:activate() end, textcolor, nil, backcolor)

	btn[1] = btn[1] + 180
	self:addButton(btn, 'Kilidini\naç', function() unlock:activate() end, textcolor, nil, backcolor)

	btn[2] = btn[2] + 140
	self:addButton(btn, 'Tekrar\nBaşlat', function() restart() end, textcolor, nil, backcolor)

	local weatherRect = {20,5,260,130}
	local weatherbox <close> = Rectangle(backcolor, true, weatherRect)
	local weatherBtn = Button(weatherRect)
	weatherBtn.renderList = RenderList()
	weatherBtn.pressedRenderList = weatherBtn.renderList
	weatherBtn:setAction( function() weatherTrends:activate() end)
	self:addChild(weatherBtn)
	self.renderList:add(weatherbox)
	local temperature = Rectangle(app.emptyTexture, {30, 15, 0, 0})
	self.renderList:add(temperature)
	local pressure = Rectangle(app.emptyTexture, {30, 55, 0, 0})
	self.renderList:add(pressure)
	local humidity = Rectangle(app.emptyTexture, {30, 95, 0, 0})
	self.renderList:add(humidity)

	local static = Rectangle(app.renderer:textureFromText(self.fontCode, '<3 Alara', textcolor ), { 300,5,0,0})
	self.renderList:add(static)

	self.stopWeatherUpdate = false
	function updateWeather()
		local font <close> = Font('media/mono.ttf',24)
		local color = Color 'f30a4ac0'
		while not self.stopWeatherUpdate do
			readLocalWeather()
			if weather.valid == false then
				if fileReadable('/tmp/weather.lua') then
					dofile('/tmp/weather.lua')
					weather.valid = false
				end
			end

			if weather.temperature ~= '' then
				temperature.texture = app.renderer:textureFromText(font, weather.temperature .. ' °C',color)
				pressure.texture = app.renderer:textureFromText(font, weather.pressure .. ' mbar',color)
				humidity.texture = app.renderer:textureFromText(font, weather.humidity .. '% RH',color)
			else
				temperature.texture = app.emptyTexture
				pressure.texture = app.emptyTexture
				humidity.texture = app.emptyTexture
			end
			self.renderList:shouldRender()
			wait(60*1000)
		end
		print 'Weather update stopped.'
	end

	addTask(updateWeather,'weather')
	
	self.renderList:add(clockRenderList)
	self.renderList:shouldRender()
end

function MainScreen:swipe(direction)
	if direction == Swipe.Left then
		mainScreen2:activate()
	end
	if direction == Swipe.Right then
		systemUpdate:activate()
	end
	if direction == Swipe.Down then
		console:setEnabled(true)
	end
	if direction == Swipe.Up then
		console:setEnabled(false)
	end
end

mainScreen = MainScreen()
