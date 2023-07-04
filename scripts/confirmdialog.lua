require 'class'
require 'gui/screen'
require 'console'

class 'ConfirmDialog' (Screen)

function ConfirmDialog:activate()
	if self.prevRenderList == nil then
		self.prevRenderList = app.overlay
	end
	if self.previousScreen then
		setCurrentScreen(self)
	else
		self.previousScreen = setCurrentScreen(self, true)
	end
	print('Set new screen:', self, 'Previous was:', self.previousScreen)
	app.overlay = self.renderList
	self.renderList:shouldRender()
end

function ConfirmDialog:deactivate()
	Screen.deactivate(self)
	app.overlay = self.prevRenderList
	app.overlay:shouldRender()
end

function ConfirmDialog:keyPressed(keyCode, codePoint)

	if keyCode == 41 then -- ESC
		self.result = 'cancel'
	end

	if keyCode == 40 or keyCode == 88 then -- enter or keypad enter
		self.result = 'ok'
	end

end

function ConfirmDialog:build()
	self.font = Font('media/pirulen.otf', 26)
	local background <close> = Rectangle(Color 'b0000000', true, {0,0,app.width, app.height})

	self.renderList:add(background)


	self.dialogWidth = 500
	self.dialogHeight = 300
	self.textWidth = 480
	self.buttonWidth = 200
	self.centre = app.width // 2
	self.dialogLeft = self.centre - self.dialogWidth//2
	self.dialogRight = self.centre + self.dialogWidth//2

	self.frameColor = Color 'f30a4a'
	self.backColor = self.frameColor:clone()
	self.backColor.a = 0x10

	local dialogBox <close> = Rectangle(self.backColor, true, {self.centre - self.dialogWidth//2, app.height//8, self.dialogWidth, self.dialogHeight})
	self.renderList:add(dialogBox)

	local dialogBox <close> = Rectangle(self.frameColor, false, {self.centre - self.dialogWidth//2, app.height//8, self.dialogWidth, self.dialogHeight})
	self.renderList:add(dialogBox)

	local btnHeight = 60
	local btnY = app.height//8 + self.dialogHeight - btnHeight

	self:addButton({self.dialogLeft, btnY, self.buttonWidth, btnHeight}, 'Tamam', function() self.result = 'ok' end, Color 'fff', self.frameColor, self.backColor)
	self:addButton({self.dialogRight-self.buttonWidth, btnY, self.buttonWidth, btnHeight}, 'Iptal', function() self.result = 'cancel' end, Color 'fff', self.frameColor, self.backColor)

end

function ConfirmDialog:run(message)
	local consoleEnabled = console:isEnabled()
	console:setEnabled(false)
	self:activate()

	local text <close> = Texture(self.font, message, Color 'fff')
	local left = self.centre - text.width // 2
	local textRect <close> = Rectangle(text, left, app.height//8+self.dialogHeight//3)

	self.renderList:add(textRect)

	self.renderList:shouldRender()

	self.result = nil
	
	while self.result == nil do
		yield()
	end

	self.renderList:remove(textRect)

	if self.previousScreen then
		self.previousScreen:activate()
	end

	console:setEnabled(consoleEnabled)

	return self.result == 'ok'
end

function confirm(message)
	print ('Confirming:', message)
	local confirmDialog = ConfirmDialog()
	local ret = confirmDialog:run(message)
	print ('Exit Confirming:', message)
	return ret
end
