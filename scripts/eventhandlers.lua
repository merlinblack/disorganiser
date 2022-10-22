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
	if type == EVENT_TOUCH_UP or type == EVENT_TOUCH_DOWN then
		print('Touched: ' .. EventNames[type])
		print(x,y)
		print(x*800,y*480)
		print(dx,dy)
	end
	if currentScreen then
		if type == EVENT_TOUCH_UP then
			currentScreen:mouseClick(app.ticks, x*app.width, y*app.height, 1)
		end
	end
end

function handleMouse(type, x, y, button, state, clicks)
	lastEvent = app.ticks
	if 0 then
		print('Mouse: ' .. EventNames[type])
		print('x,y:', x, y)
		print('button', button)
		print('state', state)
		print('clicks', clicks)
	end

	if currentScreen then
		if type == EVENT_MOUSE_BUTTONDOWN then
			if clicks == 1 then
				currentScreen:mouseClick(app.ticks, x, y, button)
			end
		end
	end
end

codepos = 1
function handleKeyUp(symbol)
	lastEvent = app.ticks
	if symbol == 's' then
		screenSaver:setDirectory('media/alara/')
		addTask(screenSaveTask, 'screensaver')
	end
end
