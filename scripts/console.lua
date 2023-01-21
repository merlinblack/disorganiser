require 'gui/widget'
require 'misc'

class 'Console' (Widget)

function Console:init()
	Widget.init(self,  {0, 0, app.width, app.height})
	self.renderList = RenderList()
	self.font = Font('media/mono.ttf', 22)
	self.enabled = false
	self.edit = EditString()
	self:build()
end

function Console:build()
	local backgroundColor = Color(64,127,64,127)
	local frameColor = Color(64,127,64,255)
	local textColor = Color(255,255,255,255)
	local cursorColor = Color(0,255,0,255)

	local rectangle <close> = Rectangle(backgroundColor, true, self:getRect())
	self.renderList:add(rectangle)

	local rectangle <close> = Rectangle(frameColor, false, shrinkRect(self:getRect(),1))
	self.renderList:add(rectangle)

	local text <close> = app.renderer:textureFromText(self.font, "Welcome to the könsole!", textColor)
	local rectangle <close> = Rectangle(text, 50, 50)
	self.renderList:add(rectangle)

	self.inputRectangle = Rectangle(app.emptyTexture, 50, 100)
	self.renderList:add(self.inputRectangle)

	self.lineHeight = self.font.lineHeight

	self.charWidth,self.charHeight = self.font:sizeText('X')
	self.charWidth = self.charWidth -1

	print('Console char w,h :', self.charWidth, self.charHeight)

	self.cursorRectangle = Rectangle(cursorColor, true, { 50, 100, self.charWidth, self.font.lineHeight})
	self.renderList:add(self.cursorRectangle)

	self.textColor = textColor
end

function Console:isEnabled()
	return self.enabled
end

function Console:toggleEnabled()
	self:setEnabled(not self.enabled)
end

function Console:setEnabled(enabled)
		self.enabled = enabled
		app.textInputMode = enabled
		if enabled then
			app.renderList:add(console.renderList)
		else
			app.renderList:remove(console.renderList)
		end
		app.renderList:shouldRender()
		print( 'Console: ', self.enabled)
end

function Console:textInput(input)
	if not self.enabled then return end

	print('Console - text input: ', input)

	self.edit:insert(input)

	self:updateInputDisplay()
end

function Console:keyUp(code, sym)
	print('Console - key up: ', code, sym)
	if code == 41 then -- Escape
		self:toggleEnabled()
	end
	if code == 42 then -- Backspace
		if self.edit:index() ~= 0 then
			self.edit:back()
			self.edit:erase()
			self:updateInputDisplay()
		end
	end
	if code == 76 then -- del
		self.edit:erase()
		self:updateInputDisplay()
	end
	if code == 79 then -- right arrow
		self.edit:forward()
		self:updateInputDisplay()
	end
	if code == 80 then -- left arrow
		self.edit:back()
		self:updateInputDisplay()
	end
end

function Console:updateInputDisplay()
	text = self.edit:getString()
	print( 'InputLine:', text)

	if text == '' then
		self.inputRectangle.texture = app.emptyTexture
	else
		local newTexture <close> = app.renderer:textureFromText(self.font, text, self.textColor)

		self.inputRectangle.texture = newTexture
	end

	self.cursorRectangle:setDest({50 + self.edit:index() * self.charWidth, 100, self.charWidth, self.font.lineHeight})

	self.renderList:shouldRender()
end

console = Console()

