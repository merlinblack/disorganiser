require 'gui/screen'
require 'weather'
require 'clock'

class 'WeatherTrends' (Screen)

function WeatherTrends:build()
	self.nextBuild = 0
	self.bigger = Font('media/mono.ttf',32)
	self.titleFont = Font('media/pirulen.otf',22)
	self.font = Font('media/mono.ttf',24)
	textcolor = Color(0xff, 0xff, 0xff, 0xff)
	backcolor = Color(0x00, 0x20, 0x7f, 0xff)
	
	local titleTexture <close> = Texture(self.titleFont, 'Hava durumu trendleri', textcolor)
	local title <close> = Rectangle(titleTexture, {(app.width//2 - titleTexture.width//2), 5, 0, 0})
	self.renderList:add(title)

	tableWidth = app.width - 150
	col1 = 10
	col2 = (tableWidth//4)*2
	col3 = (tableWidth//4)*3
	col4 = tableWidth

	local label <close> = Rectangle(Texture(self.font, 'Deg °C', textcolor), {col2, 60, 0, 0})
	self.renderList:add(label)

	local label <close> = Rectangle(Texture(self.font, 'mbar', textcolor), {col3, 60, 0, 0})
	self.renderList:add(label)

	local label <close> = Rectangle(Texture(self.font, '% RH', textcolor), {col4, 60, 0, 0})
	self.renderList:add(label)

	local label <close> = Rectangle(Texture(self.font, 'Şu anki', textcolor), {col1, 100, 0, 0})
	self.renderList:add(label)

	self.dataRenderList = RenderList()
	self.renderList:add(self.dataRenderList)
	
	self.legends = {
		increasing = Texture('media/increasing.png'),
		decreasing = Texture('media/decreasing.png'),
		stable     = Texture(self.font, '-', textcolor)
	}

	local btn = { app.width-120, app.height-clockHeight-50, 100, 50}
	self:addButton(btn, 'Geri', function() self:activatePrevious() end, textcolor, nil, backcolor)

	local btn = { app.width-280, app.height-clockHeight-50, 140, 50}
	self:addButton(btn, 'Grafikler', function() weatherGraphs.previousScreen = self.previousScreen weatherGraphs:activate(true) end, textcolor, nil, backcolor)

	function updateTask()
	
		while true do
			if self:isActive() then
				self:buildDataTable()
			end
			wait(60000)
		end

	end

	addTask(updateTask,'weatherTrends')
	addTask(function() wait(50) self:buildDataTable(true) end, 'initial weather trend build')
	
	self.renderList:add(clockRenderList)

end

function WeatherTrends:buildDataTable(force)
	local force = force or false

	if not force then
		if not self:isActive() then
			return
		end

		if self.nextBuild > app.ticks then
			return
		end
	end

	self.dataRenderList:clear()
	local textcolor = Color 'fff'

	print('Building weather trend table')
	readLocalWeather()
	readLocalWeatherTrends()

	if weather.valid == false or weatherTrendsData == nil then
		return
	end

	local label <close> = Rectangle(Texture(self.bigger, weather.temperature, textcolor), {col2, 100, 0, 0})
	self.dataRenderList:add(label)

	local label <close> = Rectangle(Texture(self.bigger, weather.pressure, textcolor), {col3, 100, 0, 0})
	self.dataRenderList:add(label)

	local label <close> = Rectangle(Texture(self.bigger, weather.humidity, textcolor), {col4, 100, 0, 0})
	self.dataRenderList:add(label)

	local row = 150

	function showInterval(interval, caption)
		local label <close> = Rectangle(Texture(self.font, caption, textcolor), {col1, row, 0, 0})
		self.dataRenderList:add(label)

		if weatherTrendsData == nil then
			local label <close> = Rectangle(Texture(self.font, 'No data', textcolor), {col2, row, 0, 0})
			self.dataRenderList:add(label)
			return
		end

		local labelTexture = self.legends[weatherTrendsData[interval].temperature]
		local label <close> = Rectangle(labelTexture, {col2, row, 0, 0})
		self.dataRenderList:add(label)

		local labelTexture = self.legends[weatherTrendsData[interval].pressure]
		local label <close> = Rectangle(labelTexture, {col3, row, 0, 0})
		self.dataRenderList:add(label)

		local labelTexture = self.legends[weatherTrendsData[interval].humidity]
		local label <close> = Rectangle(labelTexture, {col4, row, 0, 0})
		self.dataRenderList:add(label)
		
		row = row + 50
	end
	showInterval('15 minutes', '15 dakika')
	showInterval('1 hour', '1 saat')
	showInterval('12 hours', '12 saat')
	showInterval('1 week', '1 hafta')
	showInterval('1 month', '1 ay')
	self.dataRenderList:shouldRender(true)
	self.nextBuild = app.ticks + 60000
end

function WeatherTrends:swipe(direction)
	weatherGraphs:activate()
end

function WeatherTrends:activate(noUpdatePrevious)
	Screen.activate(self, noUpdatePrevious)
	addTask(function() self:buildDataTable() end, 'activation weather data table build')
end

weatherTrends = WeatherTrends()