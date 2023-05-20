require 'gui/widget'

class 'Button' (Widget)

-- Should be called on class, rather than instance.
function Button.create(rect, captionText, font, func, textColor, frameColor, backgroundColor)
	local btnWidget = Button(rect)
	btnWidget:setAction(func)

	textColor = textColor or Color 'FFF'
	frameColor = frameColor or textColor
	backgroundColor = backgroundColor or Color '000000a0'

	local rectangle <close> = Rectangle(backgroundColor, true, rect)
	btnWidget.normalRenderList:add(rectangle)

	local rectangle <close> = Rectangle( frameColor, false, rect )
	btnWidget.normalRenderList:add(rectangle)

	btnWidget.normalRenderList:add(btnWidget.captionRenderList)

	local fadeFrameColor = frameColor:clone()
	fadeFrameColor.a = fadeFrameColor.a // 3
	local rectangle <close> = Rectangle( fadeFrameColor, true, rect)
	btnWidget.pressedRenderList:add(rectangle)

	btnWidget.renderList = RenderList()
	btnWidget.renderList:add(btnWidget.normalRenderList)

	btnWidget:setCaption(captionText, textColor, font)

	btnWidget.font = font
	btnWidget.textColor = textColor

	return btnWidget
end

function Button:init( rect )
	Widget.init(self, rect)
	self.pressed = false
	self.usingPressedRenderList = false
	self.normalRenderList = RenderList()
	self.pressedRenderList = RenderList()
	self.captionRenderList = RenderList()
end

function Button:setCaption(captionText, textColor, font)

	self.captionRenderList:clear()

	if font == nil then
		font = self.font
	end

	if textColor == nil then
		textColor = self.textColor
	end

	if captionText:find('\n') then
		local position  = captionText:find('\n')
		local topLine = captionText:sub(1,position-1)
		local bottomLine = captionText:sub(position+1)

		local thirdHeight = self.height//3

		local text <close> = app.renderer:textureFromText(font, topLine, textColor)
		local rectangle <close> = Rectangle(
			text,
			self.left+((self.width//2)-(text.width//2)),
			self.top+((thirdHeight)-(text.height//2))
		)
		self.captionRenderList:add(rectangle)

		local text <close> = app.renderer:textureFromText(font, bottomLine, textColor)
		local rectangle <close> = Rectangle(
			text,
			self.left+((self.width//2)-(text.width//2)),
			self.top+((thirdHeight*2)-(text.height//2))
		)
		self.captionRenderList:add(rectangle)

	else
		if captionText == '' then
			captionText = ' '
			print 'WARNING: Empty button caption.'
			print(debug.traceback())
		end
		local text <close> = app.renderer:textureFromText(font, captionText, textColor)
		local rectangle <close> = Rectangle(
			text,
			self.left+((self.width//2)-(text.width//2)),
			self.top+((self.height//2)-(text.height//2))
		)
		self.captionRenderList:add(rectangle)
	end
end

function Button:mouseClick( time, x, y, button )
	if self:intersects( x, y ) and self.pressed then
		self:callAction(time, x, y, button)
	end
end

function Button:mouseDown( time, x, y, button )
	if self:intersects( x, y ) then
		self.pressed = true
	end
	self:updateRenderList()
end

function Button:mouseUp( time, x, y, button )
	self.pressed = false
	self:updateRenderList()
end

function Button:mouseMoved( time, x, y, button )
	if self:intersects( x, y ) then
		self.hasMouse = true
	else
		if self.hasMouse then
			self:lostMouse()
		end
	end
	self:updateRenderList()
end

function Button:lostMouse()
	self.hasMouse = false
end

function Button:updateRenderList()
	if self.hasMouse then
		if self.pressed and not self.usingPressedRenderList then
			self.usingPressedRenderList = true
			self.renderList:add(self.pressedRenderList)
			self.renderList:shouldRender()
		end
	end
	if (not self.pressed or not self.hasMouse) and self.usingPressedRenderList then
		self.usingPressedRenderList = false
		self.renderList:remove(self.pressedRenderList)
		self.renderList:shouldRender()
	end
end

function Button:setAction(func)
	self.action = func
end

function Button:callAction(time, x, y, button)
	if self.action then
		addTask(function()	self:action( time, x, y, button ) end, 'buttonHandler')
	end
end

function Button:addToRender(renderList)
	renderList:add(self.renderList)
end