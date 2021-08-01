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

yield = coroutine.yield

function wait(ms)
	local finish = app.ticks + ms
	while app.ticks < finish do
		yield()
	end
end

function task()
	for n=1,50 do
		print(n)
		wait(1000)
	end
	local rl = RenderList()
	local texture = app.renderer:textureFromFile('media/picture.jpg')
	local src = { 0, 0, texture.width, texture.height}
	local dest = { 0, 0, 800, 480}
	local rectangle = Rectangle(texture, dest, src);
	rl:add(rectangle)
	local btn = { ExitBtn.x1, ExitBtn.y1, ExitBtn.x2-ExitBtn.x1, ExitBtn.y2-ExitBtn.y1}
	local color = Color(0,0,0,0xa0)
	rectangle = Rectangle(color, true, btn)
	rl:add(rectangle)
	local font = Font('media/mono.ttf',32)
	local textcolor = Color(0xff,0x45,0x8a,0xff)
	print('render text')
	local text = app.renderer:textureFromText(font, "EXIT", textcolor)
	print(text)
	rectangle = Rectangle(
		text,
		math.floor(btn[1]+((btn[3]/2)-(text.width/2))),
		math.floor(btn[2]+((btn[4]/2)-(text.height/2)))
	)
	print(rectangle)
	rl:add(rectangle)
	app.renderList = rl
	for n=1,5 do
		print(n)
		yield()
	end
end

function collectorTask()
	wait(10000)
	collectgarbage()
end

addTask(task)
addTask(collectorTask)

-- these can get garbage collected when we are done with main.lua
local rectange
local texture
local testtext

c = Color(0xff,0x45,0x8a,0xa0)
print(c)
r = { 50, 50, 150, 100 }
rectangle = Rectangle(c, true, r);
print(rectangle)
app.renderList:add(rectangle)

texture = app.renderer:textureFromFile('media/test.png')
rectangle = Rectangle(texture, 0, 0)
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

font = Font('media/font.ttf', 26)

function updateClock()
	local color = Color(0x13,0x45,0x8a,0xff)
	local clockTexture = app.renderer:textureFromText(font, os.date(), color)
	local clockRect = Rectangle(clockTexture, 260, 8)
	app.renderList:add(clockRect)
	while true do
		clockTexture = app.renderer:textureFromText(font, os.date(), color)
		clockRect:setTexture(clockTexture)
		wait(1000)
	end
end

addTask(updateClock)

print( app.renderer)
print( app.renderList)
print( 'main.lua loaded.')