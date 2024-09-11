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
	print('Building Screen: ', self.__type)
	self:build()
end

function Screen:setStandardFont()
	self.font = Font('media/pirulen.otf', 22)
end

function Screen:build()
end

function Screen:activate(noUpdatePrevious)
	if self:isActive() then
		print( 'Screen Already activated: ', self.__type)
		return
	end
	print('Activating Screen: ', self.__type)
	if noUpdatePrevious and self.previousScreen then
		setCurrentScreen(self)
	else
		self.previousScreen = setCurrentScreen(self)
	end
	app.renderList = self.renderList
	self.renderList:shouldRender()
end

function Screen:deactivate()
	print('Deactivating Screen: ', self.__type)
end

function Screen:activatePrevious()
	if self.previousScreen then
		self.previousScreen:activate()
	end
end

function Screen:isActive()
	return getCurrentScreen() == self
end

function Screen:addButton(rect, captionText, func, textColor, frameColor, backgroundColor)
	if not self.font then
	    self:setStandardFont()
	end

	local button = Button.create(rect, captionText, self.font, func, textColor, frameColor, backgroundColor)

	button:addToRender(self.renderList)
	self:addChild(button)

	return button
end

function Screen:swipe(direction)
	print('Swipe: ' .. direction)
end
