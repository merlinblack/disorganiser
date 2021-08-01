EVENT_MOUSE_MOTION = 0x400
EVENT_MOUSE_BUTTONDOWN = 0x401
EVENT_MOUSE_BUTTONUP = 0x402
EVENT_MOUSE_WHEEL = 0x403
EVENT_TOUCH_DOWN = 0x700
EVENT_TOUCH_UP = 0x701
EVENT_TOUCH_MOTION = 0x702

EventNames = {}
EventNames[EVENT_TOUCH_DOWN] = 'touch down'
EventNames[EVENT_TOUCH_UP] = 'touch up'
EventNames[EVENT_TOUCH_MOTION] = 'touch motion'
EventNames[EVENT_MOUSE_BUTTONDOWN] = 'mouse button down'
EventNames[EVENT_MOUSE_BUTTONUP] = 'mouse button up'
EventNames[EVENT_MOUSE_MOTION] = 'mouse button motion'
EventNames[EVENT_MOUSE_WHEEL] = 'mouse button wheel'

ExitBtn = { x1 = 593, y1 = 387, x2 = 734, y2 = 454 }

function isInside( x, y, rect)
	if x < rect.x1 then return false end
	if x > rect.x2 then return false end
	if y < rect.y1 then return false end
	if y > rect.y2 then return false end
	return true
end

function handleTouch(type, x, y, dx, dy)
	if type == EVENT_TOUCH_UP or type == EVENT_TOUCH_DOWN then
		print('Touched: ' .. EventNames[type])
		print(x,y)
		print(x*800,y*480)
		print(dx,dy)

		if type == EVENT_TOUCH_UP and isInside(x*800,y*480,ExitBtn) then
			app.shouldStop = true
		end
	end
end

function handleMouse(type, x, y, button, state, clicks)
	print('Mousey:')
	print(x,y)
	print(button)
	print(state)
	print(clicks)

	if (type == EVENT_MOUSE_BUTTONUP and isInside(x,y,ExitBtn)) then
		app.shouldStop = true
	end
end

function handleKeyUp()
	print(app.ticks)
    testExceptions()
end

function task()
	for n=1,100 do
		print(n)
		coroutine.yield()
	end
end

addTask(task)

c = Color(0xff,0x45,0x8a,0xa0)
print(c)
r = { 50, 50, 150, 100 }
rectangle = Rectangle(c, true, r);
print(rectangle)
app.renderList:add(rectangle)

texture = app.renderer:textureFromFile('media/picture.jpg')
print(texture)
d = { 50, 250, 170, 150 }
s = { 290, 100, 170, 150 }
rectangle = Rectangle(texture, d, s);
print(rectangle)
app.renderList:add(rectangle)

font = Font('media/mono.ttf',64)
testtext = app.renderer:textureFromText(font, 'Bu bir testtir!', c);
rectangle = Rectangle(testtext, 210, 50);
app.renderList:add(rectangle)

print( app.renderer)
print( app.renderList)
print( 'main.lua loaded.')
