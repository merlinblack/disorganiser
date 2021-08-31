require 'clock'
require 'docker'
require 'weather'

require 'gui/screen'

class 'MainScreen' (Screen)

function MainScreen:build()
	Screen.build(self)

	local c = Color(0x92,0xee,0xee,0x20)
	local r = { 0, 0, app.width, app.height }
	local rectangle <close> = Rectangle(c, true, r);
	self.renderList:add(rectangle)

	local texture <close> = app.renderer:textureFromFile('media/falcon.png')
	local src = { 0, 0, texture.width, texture.height}
	local scale = 0.65 
	local dest = { 32, 40, math.floor(texture.width*scale), math.floor(texture.height*scale)}
	local rectangle <close> = Rectangle(texture, dest, src)
	self.renderList:add(rectangle)

	local btn = { 620, 390, 140, 70}
	local textcolor = c:clone()
	textcolor.a = 0xff
	self:addButton(btn, 'Çikiş', function() app.shouldStop = true end, textcolor)

	btn[2] = btn[2] - 100
	self:addButton(btn, 'Docker', function() docker:activate() end, textcolor)

	local weatherbox <close> = Rectangle(Color(0,0,0,0x50), true, {20,5,260,130})
	self.renderList:add(weatherbox)
	local temperature = Rectangle(app.emptyTexture, {30, 15, 0, 0})
	self.renderList:add(temperature)
	local pressure = Rectangle(app.emptyTexture, {30, 55, 0, 0})
	self.renderList:add(pressure)
	local humidity = Rectangle(app.emptyTexture, {30, 95, 0, 0})
	self.renderList:add(humidity)

	function updateWeather()
		local font <close> = Font('media/mono.ttf',34)
		local color = Color(0xfe,0x0a,0x4a,0xc0)
		while true do
			readLocalWeatherFile()
			temperature.texture = app.renderer:textureFromText(font, weather.temperature .. ' °C',color)
			pressure.texture = app.renderer:textureFromText(font, weather.pressure .. ' mbar',color)
			humidity.texture = app.renderer:textureFromText(font, weather.humidity .. '% RH',color)
			self.renderList:shouldRender()
			wait(60*1000)
		end
	end

	addTask(updateWeather)
	
	self.renderList:add(clockRenderList)
end

mainScreen = MainScreen()
