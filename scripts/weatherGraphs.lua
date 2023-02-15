require 'gui/screen'
require 'weather'
require 'clock'

class 'WeatherGraphs' (Screen)

function WeatherGraphs:build()
	self.nextBuild = 0
	self.titleFont = Font('media/pirulen.otf',22)
	self.font = Font('media/mono.ttf',24)

	self.dataRenderList = RenderList()

	self.textcolor = Color(0xff, 0xff, 0xff, 0xff)
	self.backcolor = Color(0x00, 0x20, 0x7f, 0xff)
	self.linecolor = Color(0xff, 0xff, 0xff, 0xff)

	self.tempColor = Color(0xff, 0x00, 0x00, 0xff)
	self.humColor = Color(0x40, 0x90, 0xff, 0xff)
	self.presColor = Color(0x00, 0xff, 0x00, 0xff)

	self.graphLeft = 20
	self.graphTop = 70
	self.graphBot = app.height - 100
	self.graphRight = app.width - self.graphLeft

	local titleTexture <close> = app.renderer:textureFromText(self.titleFont, 'Hava Grafikleri', self.textcolor)
	local title <close> = Rectangle(titleTexture, {(app.width//2 - titleTexture.width//2), 5, 0, 0})
	self.renderList:add(title)
	
	local subTitleTexture <close> = app.renderer:textureFromText(self.font, 'Son 24 saat', self.textcolor)
	local subTitle <close> = Rectangle(subTitleTexture, {app.width//2 - subTitleTexture.width//2, 50, 0, 0})
	self.renderList:add(subTitle)

	local tempLabel <close> = Rectangle(app.renderer:textureFromText(self.font, 'Deg °C', self.tempColor), {60, app.height-70, 0, 0})
	self.renderList:add(tempLabel)

	local pressLabel <close> = Rectangle(app.renderer:textureFromText(self.font, 'mbar', self.presColor), {200, app.height-70, 0, 0})
	self.renderList:add(pressLabel)

	local humLabel <close> = Rectangle(app.renderer:textureFromText(self.font, '% RH', self.humColor), {300, app.height-70, 0, 0})
	self.renderList:add(humLabel)

	local btn = { app.width-120, app.height-70, 100, 50}
	self:addButton(btn, 'Geri', function() mainScreen:activate() end, self.textcolor, nil, self.backcolor)

	local btn = { app.width-280, app.height-70, 140, 50}
	self:addButton(btn, 'Trendler', function() weatherTrends:activate() end, self.textcolor, nil, self.backcolor)

	local frame <close> = LineList(self.linecolor)
	frame:addPoint(self.graphLeft,self.graphTop)
	frame:addPoint(self.graphLeft,self.graphBot)
	frame:addPoint(self.graphRight, self.graphBot)
	self.renderList:add(frame)

	self.renderList:add(self.dataRenderList)

	function updateTask()
	
		while true do
			if self:isActive() then
				self:buildGraphs()
			end
			wait(60000)
		end

	end

	addTask(updateTask,'weatherGraphs')
	
	self.renderList:add(clockRenderList)

end

function WeatherGraphs:buildGraphs()
	if self.nextBuild > app.ticks then
		return
	end

	print 'Building graphs'
	self.dataRenderList:clear()

	readLocalWeatherSummary()

	if weatherSummaryData == nil then
		return
	end

	local maxTemp = -math.huge
	local minTemp = math.huge
	local maxHum = -math.huge
	local minHum = math.huge
	local maxPres = -math.huge
	local minPres = math.huge

	for _,record in pairs(weatherSummaryData) do
		if record.temperature + 0 < minTemp then
			minTemp = record.temperature + 0
		end
		if record.temperature + 0 > maxTemp then
			maxTemp = record.temperature + 0
		end
		if record.humidity + 0 < minHum then
			minHum = record.humidity + 0
		end
		if record.humidity + 0 > maxHum then
			maxHum = record.humidity + 0
		end
		if record.pressure + 0 < minPres then
			minPres = record.pressure + 0
		end
		if record.pressure + 0 > maxPres then
			maxPres = record.pressure + 0
		end
	end

	--print('Max',maxTemp,'Min',minTemp)

	local graphHeight = self.graphBot - self.graphTop
	local graphWidth = self.graphRight - self.graphLeft
	local scaleX = graphWidth // #weatherSummaryData

	local tempBottom = minTemp - 2
	local tempTop = maxTemp + 2
	local tempScaleY = graphHeight / (tempTop-tempBottom)

	local humBottom = minHum - 2
	local humTop = maxHum + 2
	local humScaleY = graphHeight / (humTop-humBottom)
	
	local presBottom = minPres - 2
	local presTop = maxPres + 2
	local presScaleY = graphHeight / (presTop-presBottom)

	local temperature <close> = LineList(self.tempColor)
	local humidity <close> = LineList(self.humColor)
	local pressure <close> = LineList(self.presColor)

	self.dataRenderList:add(temperature)
	self.dataRenderList:add(humidity)
	self.dataRenderList:add(pressure)

	local x = self.graphLeft

	for _,record in pairs(weatherSummaryData) do
		temperature:addPoint(x, math.floor(self.graphBot - (record.temperature-tempBottom) * tempScaleY))
		humidity:addPoint(x, math.floor(self.graphBot - (record.humidity-humBottom) * humScaleY))
		pressure:addPoint(x, math.floor(self.graphBot - (record.pressure-presBottom) * presScaleY))

		local tick <close> = LineList(self.linecolor)
		tick:addPoint(x, self.graphBot - 10)
		tick:addPoint(x, self.graphBot)
		self.dataRenderList:add(tick)

		x = x + scaleX
	end

	self.dataRenderList:shouldRender(true)
	self.nextBuild = app.ticks + 60000
end

function WeatherGraphs:swipe(direction)
	weatherTrends:activate()
end

function WeatherGraphs:activate()
	Screen.activate(self)
	addTask(function() weatherGraphs:buildGraphs() end, 'activation weather graph build')
end

weatherGraphs = WeatherGraphs()
addTask(function() weatherGraphs:buildGraphs() end, 'initial weather graph build')