require 'gui/widget'

class 'Button' (Widget)

-- Should be called on class, rather than instance.
function Button.create(rect, captionText, font, func, textColor, frameColor, backgroundColor)
	btnWidget = Button(rect)
	btnWidget:setAction(func)

	textColor = textColor or Color(0xff, 0xff, 0xff, 0xff)
	frameColor = frameColor or textColor
	backgroundColor = backgroundColor or Color(0, 0, 0, 0xa0)

	local renderList <close> = RenderList()

	local rectangle <close> = Rectangle(backgroundColor, true, rect)
	renderList:add(rectangle)

	local text <close> = app.renderer:textureFromText(font, captionText, textColor)
	local rectangle <close> = Rectangle(
		text,
		rect[1]+((rect[3]//2)-(text.width//2)),
		rect[2]+((rect[4]//2)-(text.height//2))
	)
	renderList:add(rectangle)
	local rectangle <close> = Rectangle( frameColor, false, rect )
	renderList:add(rectangle)

	btnWidget.normalRenderList = renderList

	btnWidget.pressedRenderList = RenderList()

	local fadeFrameColor = frameColor:clone()
	fadeFrameColor.a = fadeFrameColor.a // 3
	local rectangle <close> = Rectangle( fadeFrameColor, true, rect)
	btnWidget.pressedRenderList:add(rectangle)

	btnWidget.renderList = RenderList()
	btnWidget.renderList:add(btnWidget.normalRenderList)

	return btnWidget
end

function Button:init( rect )
	Widget.init(self, rect)
	self.pressed = false
	self.usingPressedRenderList = false
end

function Button:mouseClick( time, x, y, button )
	if self:intersects( x, y ) and self.pressed then
		if self.action then
			return self:action( time, x, y, button )
		end
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

function Button:addToRender(renderList)
	renderList:add(self.renderList)
end