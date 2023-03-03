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
end

function Screen:activate()
	self.previousScreen = setCurrentScreen(self)
	app.renderList = self.renderList
	self.renderList:shouldRender()
end

function Screen:deactivate()
end

function Screen:isActive()
	return getCurrentScreen() == self
end

function Screen:addButton(rect, captionText, func, textColor, frameColor, backgroundColor)
	if not self.font then
	    self.font = Font('media/pirulen.otf', 22)
	end

	local button = Button.create(rect, captionText, self.font, func, textColor, frameColor, backgroundColor)

	button:addToRender(self.renderList)
	self:addChild(button)

	return button
end

function Screen:swipe(direction)
	print('Swipe: ' .. direction)
end
