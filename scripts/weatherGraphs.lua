require 'gui/screen'
require 'gui/hovertext'
require 'weather'
require 'clock'

class 'WeatherGraphs'(Screen)

function WeatherGraphs:build()
	self.updateInterval = 60000
	self.hoverText = {}
	self.nextBuild = 0
	self.titleFont = Font('media/pirulen.otf', 22)
	self.font = Font('media/mono.ttf', 24)

	self.dataRenderListA = RenderList()
	self.dataRenderListB = RenderList()
	self.dataRenderList = self.dataRenderListA

	self.textcolor = Color 'fff'
	self.backcolor = Color '00207f'
	self.linecolor = Color 'fff'

	self.tempColor = Color 'f00'
	self.humColor = Color '4090ff'
	self.presColor = Color '0f0'

	self.graphLeft = 20
	self.graphTop = 70
	self.graphBot = app.height - 100
	self.graphRight = app.width - self.graphLeft

	local titleTexture <close> = Texture(self.titleFont, 'Hava Grafikleri', self.textcolor)
	local title <close> = Rectangle(titleTexture, { (app.width // 2 - titleTexture.width // 2), 5, 0, 0 })
	self.renderList:add(title)

	local subTitleTexture <close> = Texture(self.font, 'Son 24 saat', self.textcolor)
	local subTitle <close> = Rectangle(subTitleTexture, { app.width // 2 - subTitleTexture.width // 2, 50, 0, 0 })
	self.renderList:add(subTitle)

	local tempLabel <close> = Rectangle(Texture(self.font, 'Deg °C', self.tempColor), { 20, app.height - 70, 0, 0 })
	self.renderList:add(tempLabel)
	self.tempRange = Rectangle(app.emptyTexture, { 20, app.height - 50, 0, 0 })
	self.renderList:add(self.tempRange)

	local pressLabel <close> = Rectangle(Texture(self.font, 'mbar', self.presColor), { 160, app.height - 70, 0, 0 })
	self.renderList:add(pressLabel)
	self.presRange = Rectangle(app.emptyTexture, { 160, app.height - 50, 0, 0 })
	self.renderList:add(self.presRange)

	local humLabel <close> = Rectangle(Texture(self.font, '% RH', self.humColor), { 380, app.height - 70, 0, 0 })
	self.renderList:add(humLabel)
	self.humRange = Rectangle(app.emptyTexture, { 380, app.height - 50, 0, 0 })
	self.renderList:add(self.humRange)

	local btn = { app.width - 120, app.height - clockHeight - 50, 100, 50 }
	self:addButton(btn, 'Geri', function() self:activatePrevious() end, self.textcolor, nil, self.backcolor)

	local btn = { app.width - 280, app.height - clockHeight - 50, 140, 50 }
	self:addButton(btn, 'Trendler', function()
		weatherTrends.previousScreen = self.previousScreen
		weatherTrends:activate(true)
	end, self.textcolor, nil, self.backcolor)

	local frame <close> = LineList(self.linecolor)
	frame:addPoint(self.graphLeft, self.graphTop)
	frame:addPoint(self.graphLeft, self.graphBot)
	frame:addPoint(self.graphRight, self.graphBot)
	self.renderList:add(frame)

	self.renderList:add(self.dataRenderList)

	function updateTask()
		while true do
			if self:isActive() then self:buildGraphs() end
			wait(1000)
		end
	end

	addTask(updateTask, 'weatherGraphs')
	addTask(function()
		wait(10)
		self:buildGraphs(true)
	end, 'initial graph build')

	self.renderList:add(clockRenderList)
end

function WeatherGraphs:swapDataRenderList()
	self.renderList:remove(self.dataRenderList)

	if self.dataRenderList == self.dataRenderListA then
		self.dataRenderList = self.dataRenderListB
	else
		self.dataRenderList = self.dataRenderListA
	end

	self.renderList:add(self.dataRenderList)
end

function WeatherGraphs:getOffscreenDataRenderList()
	if self.dataRenderList == self.dataRenderListA then return self.dataRenderListB end

	return self.dataRenderListA
end

function WeatherGraphs:buildGraphs(force)
	local force = force or false
	local hours = hours or 24
	local showHoverText = showHoverText or true

	if not force then
		if self.buildingGraphs == true then
			print 'Already building graphs'
			return
		end

		if not self:isActive() then return end

		if self.nextBuild > app.ticks then return end
	end

	self.buildingGraphs = true

	readLocalWeatherSummary(hours)

	local rl = self:getOffscreenDataRenderList()
	rl:clear()

	print 'Building graphs'

	if weatherSummaryData == nil then return end

	local maxTemp = -math.huge
	local minTemp = math.huge
	local maxHum = -math.huge
	local minHum = math.huge
	local maxPres = -math.huge
	local minPres = math.huge

	for _, record in pairs(weatherSummaryData) do
		if record.temperature + 0 < minTemp then minTemp = record.temperature + 0 end
		if record.temperature + 0 > maxTemp then maxTemp = record.temperature + 0 end
		if record.humidity + 0 < minHum then minHum = record.humidity + 0 end
		if record.humidity + 0 > maxHum then maxHum = record.humidity + 0 end
		if record.pressure + 0 < minPres then minPres = record.pressure + 0 end
		if record.pressure + 0 > maxPres then maxPres = record.pressure + 0 end
	end

	self.tempRange.texture = Texture(self.font, minTemp .. '-' .. maxTemp, self.tempColor)
	self.presRange.texture = Texture(self.font, minPres .. '-' .. maxPres, self.presColor)
	self.humRange.texture = Texture(self.font, minHum .. '-' .. maxHum, self.humColor)

	local graphHeight = self.graphBot - self.graphTop
	local graphWidth = self.graphRight - self.graphLeft
	local scaleX = graphWidth // (#weatherSummaryData - 1)

	local tempBottom = minTemp - 2
	local tempTop = maxTemp + 2
	local tempScaleY = graphHeight / (tempTop - tempBottom)

	local humBottom = minHum - 2
	local humTop = maxHum + 2
	local humScaleY = graphHeight / (humTop - humBottom)

	local presBottom = minPres - 2
	local presTop = maxPres + 2
	local presScaleY = graphHeight / (presTop - presBottom)

	local white = Color 'fff'

	local temperature <close> = LineList(self.tempColor)
	local humidity <close> = LineList(self.humColor)
	local pressure <close> = LineList(self.presColor)

	rl:add(temperature)
	rl:add(humidity)
	rl:add(pressure)

	local x = self.graphLeft

	local newHoverText = {}
	local yieldcount = 0

	for _, record in pairs(weatherSummaryData) do
		yieldcount = yieldEveryN(yieldcount, 4)

		y = math.floor(self.graphBot - (record.temperature - tempBottom) * tempScaleY)
		temperature:addPoint(x, y)
		if showHoverText then
			table.insert(
				newHoverText,
				HoverText({ x - 3, y - 3, 6, 6 }, record.temperature, self.tempColor, self.tempColor, self.font)
			)
		end

		y = math.floor(self.graphBot - (record.humidity - humBottom) * humScaleY)
		humidity:addPoint(x, y)
		if showHoverText then
			table.insert(
				newHoverText,
				HoverText({ x - 3, y - 3, 6, 6 }, record.humidity, self.humColor, self.humColor, self.font)
			)
		end

		y = math.floor(self.graphBot - (record.pressure - presBottom) * presScaleY)
		pressure:addPoint(x, y)
		if showHoverText then
			table.insert(
				newHoverText,
				HoverText({ x - 3, y - 3, 6, 6 }, record.pressure, self.presColor, self.presColor, self.font)
			)
		end

		local tick <close> = LineList(self.linecolor)
		tick:addPoint(x, self.graphBot - 10)
		tick:addPoint(x, self.graphBot)
		if showHoverText then
			table.insert(
				newHoverText,
				HoverText({ x - 2, self.graphBot - 12, 4, 4 }, record.time, white, white, self.font)
			)
		end
		rl:add(tick)

		x = x + scaleX
	end

	for _, hoverText in pairs(self.hoverText) do
		hoverText:removeFromScreen(self)
	end

	self.hoverText = newHoverText

	for _, hoverText in pairs(newHoverText) do
		hoverText:addToScreen(self)
	end

	print 'Finshed graph build'
	rl:shouldRender(true)
	self:swapDataRenderList()
	self.nextBuild = app.ticks + self.updateInterval
	self.buildingGraphs = false
end

function WeatherGraphs:swipe(direction)
	weatherTrends.previousScreen = self.previousScreen
	weatherTrends:activate(true)
end

function WeatherGraphs:activate(noUpdatePrevious)
	Screen.activate(self, noUpdatePrevious)
	addTask(function() weatherGraphs:buildGraphs() end, 'activation weather graph build')
end

weatherGraphs = WeatherGraphs()
