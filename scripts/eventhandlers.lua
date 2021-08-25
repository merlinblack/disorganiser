require 'events'
require 'eventnames'
currentScreen = nil

function setCurrentScreen(newScreen)
	currentScreen = newScreen
end

function handleTouch(type, x, y, dx, dy)
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
	print('Mouse: ' .. EventNames[type])
	print('x,y:', x, y)
	print('button', button)
	print('state', state)
	print('clicks', clicks)

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
	code = {110,117,100,101}
	print(symbol)
	if code[codepos] == symbol then
		codepos = codepos + 1
		if codepos == 5 then
			addTask(task)
			codepos = 1
		end
	else
		codepos = 1
	end
	print(codepos)
end
