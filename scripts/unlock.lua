require 'gui/screen'

class 'Unlock' (Screen)

function Unlock:build()
	self.font = Font('media/Aurek-Besh.ttf', 18)

	local buttonWidth = 100
	local buttonHeight = 100
	local buttonGap = 10

	local width = secret.width * buttonWidth + (secret.width-1) * buttonGap
	local height = secret.height * buttonHeight + (secret.height-1) * buttonGap
	local left = (app.width/2) - (width/2)
	local top = ((app.height-clockHeight)/2) - (height/2)

	local buttonIndex = 1
	local textcolor = Color(0xfe,0x0a,0x4a,0xff)
	local backcolor = textcolor:clone()
	backcolor.a = 0x20
	for row = 1, secret.height do
		for col = 1, secret.width do
			local btn = { left + (col-1)*(buttonWidth+buttonGap), top + (row-1) * (buttonHeight+buttonGap), buttonWidth, buttonHeight}
			self:addButton(btn, secret.buttons[buttonIndex], self:getBtnPressedClosure(secret.buttons[buttonIndex]), textcolor, nil, backcolor)
			buttonIndex = buttonIndex + 1
		end
	end
	btn = { app.width-105, app.height-clockHeight-70, 100, 60}
	self:addButton(btn, 'G', function() mainScreen:activate() end, textcolor, nil, backcolor)

	self.animation = Rectangle(app.emptyTexture, {app.width//8,5,0,0})
	self.renderList:add(self.animation)
end

function Unlock:activate()
	Screen.activate(self)
	self.code = ''
end

function Unlock:getBtnPressedClosure(value)
	local v = value
	return function() self:btnPressed(v) end
end

function Unlock:btnPressed(value)
	self.code = self.code .. value
	print ('Code:', self.code)
	local color = Color(0xfe,0x0a,0x4a,0xc0)
	self.animation.texture = Texture(self.font, #self.code .. ' ' .. self.code, color )
	self.renderList:shouldRender()
	if self.code == secret.pass then
		Unlock:unlock('media/special/')
	end
	if self.code == secret.pass2 then
		Unlock:unlock('media/special2/')
	end
end

function Unlock:unlock(directory)
	print('Unlocked')
	screenSaver:setDirectory(directory)
	addTask(screenSaveTask, 'screensaver')
end

function Unlock:swipe(direction)
	if direction == Swipe.Left then
		systemUpdate:activate()
	end
	if direction == Swipe.Right then
		mainScreen2:activate()
	end
	if direction == Swipe.Down then
		console:setEnabled(true)
	end
	if direction == Swipe.Up then
		console:setEnabled(false)
	end
end

unlock = Unlock()