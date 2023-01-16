require 'events'
require 'eventnames'

-- Perhaps this should be part of screen class?
currentScreen = nil
lastEvent = 0

function setCurrentScreen(newScreen)
	if currentScreen then
		currentScreen:deactivate()
	end
	currentScreen = newScreen
end

function getCurrentScreen()
	return currentScreen
end

function handleTouch(type, x, y, dx, dy)
	lastEvent = app.ticks
	if false then
		print('Touched: ' .. EventNames[type])
		print(x,y)
		print(x*app.width,y*app.height)
		print(dx,dy)
	end
	if currentScreen then
		if type == EVENT_TOUCH_MOTION then
			currentScreen:mouseMoved(app.ticks, x*app.width, y*app.height, 1)
		end
		if type == EVENT_TOUCH_DOWN then
			currentScreen:mouseDown(app.ticks, x*app.width, y*app.height, 1)
		end
		if type == EVENT_TOUCH_UP then
			currentScreen:mouseClick(app.ticks, x*app.width, y*app.height, 1)
			currentScreen:mouseUp(app.ticks, x*app.width, y*app.height, 1)
		end
	end
end

function handleMouse(type, x, y, button, state, clicks)
	lastEvent = app.ticks
	if false then
		print('Mouse: ' .. EventNames[type])
		print('x,y:', x, y)
		print('button', button)
		print('state', state)
		print('clicks', clicks)
	end

	if currentScreen then
		if type == EVENT_MOUSE_MOTION then
			currentScreen:mouseMoved(app.ticks, x, y, button)
		end
		if type == EVENT_MOUSE_BUTTONUP then
			if clicks == 1 then
				currentScreen:mouseClick(app.ticks, x, y, button)
			end
			currentScreen:mouseUp(app.ticks, x, y, button)
		end
		if type == EVENT_MOUSE_BUTTONDOWN then
			currentScreen:mouseDown(app.ticks, x, y, button)
		end
	end
end

function handleKeyUp(symbol)
	lastEvent = app.ticks
	if symbol == 's' then
		screenSaver:setDirectory('media/alara/')
		addTask(screenSaveTask, 'screensaver')
	end
end
