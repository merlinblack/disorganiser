require 'events'
require 'eventnames'
require 'console'

-- Perhaps this should be part of screen class?
currentScreen = nil

lastEvent = 0
consoleActive = false
mouseDown = false
swipeStart = nil
fingerDown = false
lastMouseEvent = -math.huge

function setCurrentScreen(newScreen, noDeactivate)
	local previousScreen = currentScreen
	if currentScreen and noDeactivate == nil then
		currentScreen:deactivate()
	end
	currentScreen = newScreen

	return previousScreen
end

function getCurrentScreen()
	return currentScreen
end

addTask(
	function()
		while true do
			if currentScreen then
				currentScreen:update()
			end
			wait(1000)
		end
	end,
	'Screen update'
)

function handleTouch(type, x, y, dx, dy)
	lastEvent = app.ticks
	-- looks like Raspian is setup to send synthetic mouse events. So we can't turn them off.
	-- So turn the cursor back off here (mouse events come first)
	app.showCursor = false
	stopHideCursorTask = true

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
			local lx = x * app.width
			local ly = y * app.height
			currentScreen:mouseDown(app.ticks, lx, ly, 1)
			fingerDown = true
			swipeStart = {x=lx, y=ly}
		end
		if type == EVENT_TOUCH_UP then
			local lx = x * app.width
			local ly = y * app.height
			local swipeDirection = detectSwipe(swipeStart, lx, ly)
			mouseDown = false
			swipeStart = nil
			if swipeDirection == Swipe.None then
				currentScreen:mouseClick(app.ticks, lx, ly, 1)
			else
				currentScreen:swipe(swipeDirection)
			end
			currentScreen:mouseUp(app.ticks, lx, ly, 1)
		end
	end
end

function handleMouse(type, x, y, button, state, clicks, which)
	lastEvent = app.ticks
	lastMouseEvent = lastEvent
	showCursor()
	if false then
		print('Mouse: ' .. EventNames[type])
		print('x,y:', x, y)
		print('button', button)
		print('state', state)
		print('clicks', clicks)
		print('which', which)
	end

	if currentScreen then
		if type == EVENT_MOUSE_MOTION then
			currentScreen:mouseMoved(app.ticks, x, y, button)
		end
		if type == EVENT_MOUSE_BUTTONUP then
			local swipeDirection = detectSwipe(swipeStart, x, y)
			mouseDown = false
			swipeStart = nil
			if swipeDirection == Swipe.None then
				currentScreen:mouseClick(app.ticks, x, y, button)
			else
				currentScreen:swipe(swipeDirection)
			end
			currentScreen:mouseUp(app.ticks, x, y, button)
		end
		if type == EVENT_MOUSE_BUTTONDOWN then
			mouseDown = true
			swipeStart = {x=x, y=y}
			currentScreen:mouseDown(app.ticks, x, y, button)
		end
	end
end

function detectSwipe(start, endX, endY)
	local threshold = 50

	if start.x - endX > threshold then
		return Swipe.Left
	end

	if endX - start.x > threshold then
		return Swipe.Right
	end

	if start.y - endY > threshold then
		return Swipe.Up
	end

	if endY - start.y > threshold then
		return Swipe.Down
	end

	return Swipe.None
end

function handleKeyUp(code, sym)
	--print('handleKeyUp()', code, sym)
	killTask('keyRepeatTask')
	lastEvent = app.ticks
	if not console:isEnabled() then
		if code == 41 and not quitting == true then -- Escape
			restart()
		elseif sym == 's' then
			startScreenSave()
		elseif sym == '`' then
			console:toggleEnabled()
		else
			currentScreen:keyPressed(code, sym)
		end
	else
		console:keyUp(code, sym)
	end
end

function handleKeyDown(code, sym)
	addUniqueTask(
		function()
			local keyCode = code
			local keySym = sym
			local status = wait(1000)
			while status ~= 'killed' and console:isEnabled() do
				console:keyUp(keyCode,keySym)
				status = wait(100)
			end
		end,
		'keyRepeatTask'
	)
end

function handleTextInput(text)
	console:textInput(text)
end

function hideCursorTask()
	stopHideCursorTask = false
	while not stopHideCursorTask do
		wait(1000)
		if lastMouseEvent + 5000 < app.ticks then
			app.showCursor = false
			stopHideCursorTask = true
		end
	end
end

function showCursor()
	app.showCursor = true
	addUniqueTask(hideCursorTask, 'hideCursorTask')
end