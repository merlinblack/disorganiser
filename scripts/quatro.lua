require 'gui/screen'
require 'gui/inputgroup'
local json = require 'json'

class 'QuatroDisplay'(Screen)

function QuatroDisplay:build()
	Screen.build(self)

	self.temperature = 20.0
	self.humidity = 50
	self.tvoc = 100
	self.pressure = 1020.0

	self.currentPage = RenderList()
	self.currentPageNumber = 1
	self.pages = { RenderList(), RenderList() }

	self.clockColor = Color 'ff7f7f7f'
	local backgroundColor = Color 'ff202020'

	self.font = Font('media/mono.ttf', 42)
	self.clockFont = Font('media/digital7.ttf', 256 + 64)

	local background <close> = Rectangle(backgroundColor, true, { 0, 0, app.width, app.height })
	self.renderList:add(background)
	self.renderList:add(self.currentPage)

	self:buildPageOne()
	self:buildPageTwo()
	self:buildDataDisplay()
	self:setPage(1)
end

function QuatroDisplay:buildPageOne()
	local clockWidth = 1400
	local clockHeight = 500
	self.clockRect = Rectangle(Texture(self.clockFont, self:getClockText(), self.clockColor), {
		app.width // 2 - clockWidth // 2,
		app.height // 2 - clockHeight // 2,
		0,
		0,
	})
	self.pages[1]:add(self.clockRect)
end

function QuatroDisplay:buildPageTwo()
	local width = 300
	local height = 80
	local btn = { app.width // 2 - width // 2, 150, width, height }
	local spacing = 150

	local backcolor = Color 'ff404040'

	self.pageTwoInput = InputGroup { btn[1], btn[2], width, (height + spacing) * 5 }
	self.pageTwoInput.font = self.font

	self.pageTwoInput:addButton(
		btn,
		'Photos',
		function() startScreenSave() end,
		textcolor,
		framecolor,
		backcolor,
		self.pages[2]
	)

	btn[2] = btn[2] + spacing
	self.pageTwoInput:addButton(
		btn,
		'Suspend',
		function() suspend:activate() end,
		textcolor,
		framecolor,
		backcolor,
		self.pages[2]
	)

	btn[2] = btn[2] + spacing
	self.pageTwoInput:addButton(btn, 'Quit', function() quit() end, textcolor, framecolor, backcolor, self.pages[2])

	btn[2] = btn[2] + spacing
	self.pageTwoInput:addButton(
		btn,
		'Restart',
		function() restart() end,
		textcolor,
		framecolor,
		backcolor,
		self.pages[2]
	)

	btn[2] = btn[2] + spacing
	self.pageTwoInput:addButton(
		btn,
		'Power off',
		function() poweroff() end,
		textcolor,
		framecolor,
		backcolor,
		self.pages[2]
	)

	self:addChild(self.pageTwoInput)
	self.pageTwoInput:enable(false)
end

function QuatroDisplay:buildDataDisplay()
	local frameColor = Color '2f2f6f2f'
	local backColor = Color 'ff1a1a1a'
	local spacing = (app.width - (450 * 4)) // 5
	local left = spacing
	local top = app.height - 125

	self.temperatureRect = self:pill(left, top, frameColor, backColor)
	left = left + 450 + spacing

	self.humidityRect = self:pill(left, top, frameColor, backColor)
	left = left + 450 + spacing

	self.tvocRect = self:pill(left, top, frameColor, backColor)
	left = left + 450 + spacing

	self.pressureRect = self:pill(left, top, frameColor, backColor)
	left = left + 450 + spacing

	self:updateView()
end

function QuatroDisplay:pill(left, top, frameColor, backColor)
	local rrect <close> = RoundedRectangle(frameColor, { left, top, 450, 100 }, 10, backColor)

	local rect = Rectangle(app.emptyTexture, { left + 30, top + 30, 0, 0 })

	self.renderList:add(rrect)
	self.renderList:add(rect)

	return rect
end

function QuatroDisplay:setPage(num)
	self.currentPageNumber = num
	self.currentPage:clear()
	self.currentPage:add(self.pages[self.currentPageNumber])
	self.currentPage:shouldRender()

	self.pageTwoInput:enable(self.currentPageNumber == 2)
end

function QuatroDisplay:swipe(direction)
	local num = self.currentPageNumber

	if num < 2 then
		num = num + 1
	else
		num = 1
	end
	self:setPage(num)
end

function QuatroDisplay:activate(noUpdatePrevious)
	Screen.activate(self, noUpdatePrevious)
	self:setPage(1)
end

function QuatroDisplay:updateClock()
	self.clockRect.texture = Texture(self.clockFont, self:getClockText(), self.clockColor)
	self.renderList:shouldRender()
end

function QuatroDisplay:getClockText()
	local text
	if os.time() % 2 == 0 then
		text = os.date '%I:%M %p' .. ''
	else
		text = os.date '%I %M %p' .. ''
	end
	return text
end

function QuatroDisplay:updateView()
	self.temperatureRect.texture = Texture(self.font, ('Temp: %.2f °C'):format(self.temperature), textcolor)
	self.humidityRect.texture = Texture(self.font, ('Hum: %.2f RH'):format(self.humidity), textcolor)
	self.tvocRect.texture = Texture(self.font, ('TVOC: %d ppb'):format(self.tvoc), textcolor)
	self.pressureRect.texture = Texture(self.font, ('Pres: %.2f mbar'):format(self.pressure), textcolor)
	self.renderList:shouldRender()
end

function QuatroDisplay:updateData()
	local jsonStr = self:run 'mcp9808'
	local data = json.decode(jsonStr)
	self.temperature = data.temperature
	yield()

	local jsonStr = self:run 'aht10'
	local data = json.decode(jsonStr)
	self.humidity = data.humidity
	yield()

	local jsonStr = self:run 'ags10_simple'
	local data = json.decode(jsonStr)
	self.tvoc = data.tvoc
	yield()

	local jsonStr = self:run 'bmp280'
	local data = json.decode(jsonStr)
	self.pressure = data.pressure
	yield()

	self:updateView()
end

function QuatroDisplay:run(program)
	local proc <close> = SubProcess()

	print(program)

	proc:set 'ssh'
	proc:add 'quatro.local'
	proc:add(program)
	proc:add '--json'
	proc:open()

	local more = true
	local results = ''
	local part = ''
	while more do
		more, part = proc:read()
		part = string.gsub(part, '^%s*(.-)%s*$', '%1')
		results = results .. part
		yield()
	end

	print(results)

	return results
end

quatroDisplay = QuatroDisplay()

function quatroUpdateTask()
	local clock = 0
	local nextDataTime = 0

	while not stopQuatro do
		if clock < os.time() then
			quatroDisplay:updateClock()
			clock = os.time()
		end
		if nextDataTime < os.time() then
			addTask(function() quatroDisplay:updateData() end, 'update quatro data')
			nextDataTime = os.time() + 30
		end
		waitSeconds(1)
	end
end
