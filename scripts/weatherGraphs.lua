require 'gui/screen'
require 'gui/hovertext'
require 'weather'
require 'clock'

class 'WeatherGraphs' (Screen)

function WeatherGraphs:build()
	self.hoverText = {}
	self.nextBuild = 0
	self.titleFont = Font('media/pirulen.otf',22)
	self.font = Font('media/mono.ttf',24)

	self.dataRenderList = RenderList()

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
	local title <close> = Rectangle(titleTexture, {(app.width//2 - titleTexture.width//2), 5, 0, 0})
	self.renderList:add(title)
	
	local subTitleTexture <close> = Texture(self.font, 'Son 24 saat', self.textcolor)
	local subTitle <close> = Rectangle(subTitleTexture, {app.width//2 - subTitleTexture.width//2, 50, 0, 0})
	self.renderList:add(subTitle)

	local tempLabel <close> = Rectangle(Texture(self.font, 'Deg °C', self.tempColor), {20, app.height-70, 0, 0})
	self.renderList:add(tempLabel)
	self.tempRange = Rectangle(app.emptyTexture, {20, app.height-50, 0, 0})
	self.renderList:add(self.tempRange)

	local pressLabel <close> = Rectangle(Texture(self.font, 'mbar', self.presColor), {160, app.height-70, 0, 0})
	self.renderList:add(pressLabel)
	self.presRange = Rectangle(app.emptyTexture, {160, app.height-50, 0, 0})
	self.renderList:add(self.presRange)

	local humLabel <close> = Rectangle(Texture(self.font, '% RH', self.humColor), {380, app.height-70, 0, 0})
	self.renderList:add(humLabel)
	self.humRange = Rectangle(app.emptyTexture, {380, app.height-50, 0, 0})
	self.renderList:add(self.humRange)

	local btn = { app.width-120, app.height-clockHeight-50, 100, 50}
	self:addButton(btn, 'Geri', function() mainScreen:activate() end, self.textcolor, nil, self.backcolor)

	local btn = { app.width-280, app.height-clockHeight-50, 140, 50}
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
	addTask(function() wait(100) self:buildGraphs(true) end, 'initial graph build')
	
	self.renderList:add(clockRenderList)

end

function WeatherGraphs:buildGraphs(force)
	local force = force or false
	local hours = hours or 24
	local showHoverText = showHoverText or true

	if not force then
		if not self:isActive() then
			return
		end

		if self.nextBuild > app.ticks then
			return
		end
	end

	readLocalWeatherSummary(hours)

	print 'Building graphs'
	self.dataRenderList:clear()
	write(os.date(),'Number of hoverText to remove: ', #self.hoverText)
	for _,hoverText in pairs(self.hoverText) do
		hoverText:removeFromScreen(self)
	end
	self.hoverText = {}

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
	self.tempRange.texture = Texture(self.font, minTemp .. '-' .. maxTemp, self.tempColor)
	self.presRange.texture = Texture(self.font, minPres .. '-' .. maxPres, self.presColor)
	self.humRange.texture = Texture(self.font, minHum .. '-' .. maxHum, self.humColor)

	local graphHeight = self.graphBot - self.graphTop
	local graphWidth = self.graphRight - self.graphLeft
	local scaleX = graphWidth // (#weatherSummaryData-1)

	local tempBottom = minTemp - 2
	local tempTop = maxTemp + 2
	local tempScaleY = graphHeight / (tempTop-tempBottom)

	local humBottom = minHum - 2
	local humTop = maxHum + 2
	local humScaleY = graphHeight / (humTop-humBottom)
	
	local presBottom = minPres - 2
	local presTop = maxPres + 2
	local presScaleY = graphHeight / (presTop-presBottom)

	local white = Color 'fff'

	local temperature <close> = LineList(self.tempColor)
	local humidity <close> = LineList(self.humColor)
	local pressure <close> = LineList(self.presColor)

	self.dataRenderList:add(temperature)
	self.dataRenderList:add(humidity)
	self.dataRenderList:add(pressure)

	local x = self.graphLeft

	for _,record in pairs(weatherSummaryData) do
		y = math.floor(self.graphBot - (record.temperature-tempBottom) * tempScaleY)
		temperature:addPoint(x, y)
		if showHoverText then
			table.insert(self.hoverText,HoverText({x-3, y-3, 6, 6}, record.temperature, self.tempColor, self.tempColor, self.font))
		end

		y = math.floor(self.graphBot - (record.humidity-humBottom) * humScaleY)
		humidity:addPoint(x, y)
		if showHoverText then
			table.insert(self.hoverText,HoverText({x-3, y-3, 6, 6}, record.humidity, self.humColor, self.humColor, self.font))
		end

		y = math.floor(self.graphBot - (record.pressure-presBottom) * presScaleY)
		pressure:addPoint(x, y)
		if showHoverText then
			table.insert(self.hoverText,HoverText({x-3, y-3, 6, 6}, record.pressure, self.presColor, self.presColor, self.font))
		end

		local tick <close> = LineList(self.linecolor)
		tick:addPoint(x, self.graphBot - 10)
		tick:addPoint(x, self.graphBot)
		if showHoverText then
			table.insert(self.hoverText,HoverText({x-2, self.graphBot-12, 4, 4}, record.time, white, white, self.font))
		end
		self.dataRenderList:add(tick)

		x = x + scaleX
	end

	for _, hoverText in pairs(self.hoverText) do
		hoverText:addToScreen(self)
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