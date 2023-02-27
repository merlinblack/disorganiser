require 'class'
require 'gui/screen'

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
	print('Deactivating:', self)
	app.overlay = self.prevRenderList
	app.overlay:shouldRender()
end

function ConfirmDialog:build()
	self.font = Font('media/pirulen.otf', 26)
	local background <close> = Rectangle(Color '000000b0', true, {0,0,app.width, app.height})

	self.renderList:add(background)


	local dialogWidth = 500
	local dialogHeight = 300
	local textWidth = 480
	local centre = app.width // 2
	local dialogLeft = centre - dialogWidth//2
	local dialogRight = centre + dialogWidth//2

	local frameColor = Color 'f30a4a'
	local backColor = frameColor:clone()
	backColor.a = 0x10

	local dialogBox <close> = Rectangle(backColor, true, {centre - dialogWidth//2, app.height//8, dialogWidth, dialogHeight})
	self.renderList:add(dialogBox)

	local dialogBox <close> = Rectangle(frameColor, false, {centre - dialogWidth//2, app.height//8, dialogWidth, dialogHeight})
	self.renderList:add(dialogBox)

	local buttonWidth = 200
	self:addButton({dialogLeft, dialogHeight, buttonWidth, 60}, 'Tamam', function() self.result = 'ok' end, Color 'fff', frameColor, backColor)
	self:addButton({dialogRight-buttonWidth, dialogHeight, buttonWidth, 60}, 'Iptal', function() self.result = 'cancel' end, Color 'fff', frameColor, backColor)

end

function ConfirmDialog:run(message)
	self:activate()

	local centre = app.width // 2

	local text <close> = app.renderer:textureFromText(self.font, message, Color 'fff')
	local left = centre - text.width // 2
	local textRect <close> = Rectangle(text, left, app.height//4)

	self.renderList:add(textRect)

	self.renderList:shouldRender()

	self.result = nil
	
	while self.result == nil do
		yield()
	end

	self.renderList:remove(textRect)

	self.previousScreen:activate()

	return self.result == 'ok'
end

function confirm(message)
	print ('Confirming:', message)
	local confirmDialog = ConfirmDialog()
	local ret = confirmDialog:run(message)
	print ('Exit Confirming:', message)
	return ret
end
