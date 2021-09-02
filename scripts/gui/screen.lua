require 'class'
require 'gui/widget'
require 'gui/button'
require 'eventhandlers'

--[[
-- A screen is a whole screen filling UI, containing other elements
-- and a background.
-- Only one is active at any time.
-- Maintains their own render list - only the active screens list is 
-- rendered.
-- User input is sent to the active screen only.
--]]

class 'Screen' (Widget)

function Screen:init()
	Widget.init(self,  {0, 0, app.width, app.height})
	self.renderList = RenderList()
	self:build()
end

function Screen:build()
	self.font = Font('media/mono.ttf',24)
end

function Screen:activate()
	setCurrentScreen(self)
	app.renderList = self.renderList
	self.renderList:shouldRender()
end

function Screen:deactivate()
end

function Screen:addButton(rect, captionText, func, textColor, frameColor, backgroundColor)
	textColor = textColor or Color(0xff, 0xff, 0xff, 0xff)
	frameColor = frameColor or textColor
	backgroundColor = backgroundColor or Color(0, 0, 0, 0xa0)

	local rectangle <close> = Rectangle(backgroundColor, true, rect)
	self.renderList:add(rectangle)

	local text <close> = app.renderer:textureFromText(self.font, captionText, textColor)
	local rectangle <close> = Rectangle(
		text,
		rect[1]+((rect[3]//2)-(text.width//2)),
		rect[2]+((rect[4]//2)-(text.height//2))
	)
	self.renderList:add(rectangle)
	local rectangle <close> = Rectangle( frameColor, false, rect )
	self.renderList:add(rectangle)

	btnWidget = Button(rect)
	btnWidget:setAction(func)
	self:addChild(btnWidget)
end