require 'gui/screen'


---@class LedTouch : Screen
LedTouch={}

class 'LedTouch' (Screen)

function LedTouch:init()
	self.indexToLines = {}
	self.indexToLines[0] = 17
	self.indexToLines[1] = 18
	self.indexToLines[2] = 21
	self.indexToLines[3] = 22
	self.indexToLines[4] = 23
	self.indexToLines[5] = 24
	self.indexToLines[6] = 25
	self.indexToLines[7] = 4
	self.indexState = {}
	self.indexState[0] = false
	self.indexState[1] = false
	self.indexState[2] = false
	self.indexState[3] = false
	self.indexState[4] = false
	self.indexState[5] = false
	self.indexState[6] = false
	self.indexState[7] = false
	Screen.init(self)
end

function LedTouch:build()
	local textColor = Color 'FFE3EE0A'
	local frameColor = Color 'FF058598'
	local backgroundColor = Color '11a5a5a5'

	local margin = 50

	local buttonWidth = 75
	local buttonHeight = 75
	local buttonGap = (app.width - (8 * buttonWidth) - (2 * margin)) // 8

	local buttonTop = app.height//2 - buttonHeight //2

	local x = margin
	for led = 0,7 do
		local rect = {x, buttonTop, buttonWidth, buttonHeight}
		self:addButton(rect, ''..led, self:getBtnPressedClosure(led), textColor, frameColor, backgroundColor)
		x = x + buttonGap + buttonWidth
	end
	local rect = {0, 0, 150, buttonHeight}
	self:addButton(rect, 'Reset', function(self) self.parent:reset() end, textColor, frameColor, backgroundColor)
	self:addButton({app.width-105, app.height-clockHeight-70, 100, 60}, 'Geri', function() mainScreen:activate() end, textColor, frameColor, backgroundColor)

end

function LedTouch:getBtnPressedClosure(ledIndex)
	local index = ledIndex
	return function(self) self.parent:toggleLED(index) end
end

function LedTouch:toggleLED(index)
	write('Toggle led: ' .. index)
	self.indexState[index] = not self.indexState[index]
	local value = 0
	if self.indexState[index] then
		value = 1
	end
	local line = self.indexToLines[index]
	self:sshModelB('gpioset gpiochip0 ' .. line .. '=' .. value)
end

function LedTouch:reset()
	local command = ''
	for index = 0, 7 do
		local line = self.indexToLines[index]
		self.indexState[index] = false
		command = command .. 'gpioset gpiochip0 ' .. line .. '=0;'
	end
	self:sshModelB(command)
end

function LedTouch:sshModelB(command)
	write ('ModelB command: ' .. command)
	local proc <close> = ProcessReader()

	proc:set('ssh')
	proc:add('modelb.local')
	proc:add(command)
	proc:open()

	local more = true
	local results
	while more do
		more, results = proc:read()
		results = string.gsub(results, '^%s*(.-)%s*$', '%1')

		if results ~= '' then
			write(results)
		end
		yield()
	end
end

ledtouch = LedTouch()