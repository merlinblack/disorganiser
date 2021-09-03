require 'clock'
require 'docker'
require 'weather'

require 'gui/screen'

class 'MainScreen' (Screen)

function MainScreen:build()
	Screen.build(self)

	local texture <close> = app.renderer:textureFromFile('media/vader.jpg')
	local src = { 0, 0, texture.width, texture.height}
	local dest = {0, 0, app.width, app.height}
	local rectangle <close> = Rectangle(texture, dest, src)
	self.renderList:add(rectangle)

	local btn = { 30, 300, 140, 70}
	local textcolor = Color(0xfe,0x0a,0x4a,0xff)
	local backcolor = textcolor:clone()
	backcolor.a = 0x20
	self:addButton(btn, 'Çikiş', function() app.shouldStop = true end, textcolor, nil, backcolor)

	btn[2] = btn[2] - 100
	self:addButton(btn, 'Docker', function() docker:activate() end, textcolor, nil,backcolor)

	local weatherbox <close> = Rectangle(backcolor, true, {20,5,260,130})
	self.renderList:add(weatherbox)
	local temperature = Rectangle(app.emptyTexture, {30, 15, 0, 0})
	self.renderList:add(temperature)
	local pressure = Rectangle(app.emptyTexture, {30, 55, 0, 0})
	self.renderList:add(pressure)
	local humidity = Rectangle(app.emptyTexture, {30, 95, 0, 0})
	self.renderList:add(humidity)

	self.stopWeatherUpdate = false

	function updateWeather()
		local font <close> = Font('media/mono.ttf',24)
		local color = Color(0xfe,0x0a,0x4a,0xc0)
		while not self.stopWeatherUpdate do
			readLocalWeatherFile()
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
end

mainScreen = MainScreen()
