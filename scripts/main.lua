require 'events'
require 'eventnames'

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

yield = coroutine.yield

function wait(ms)
	local finish = app.ticks + ms
	while app.ticks < finish do
		yield()
	end
end

function task()
	wait(1000)

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
	local font = Font('media/mono.ttf',24)
	local textcolor = Color(0xff,0x45,0x8a,0xff)
	print('render text')
	local text = app.renderer:textureFromText(font, "Exit", textcolor)
	print(text)
	rectangle = Rectangle(
		text,
		btn[1]+((btn[3]//2)-(text.width//2)),
		btn[2]+((btn[4]//2)-(text.height//2))
	)
	print(rectangle)
	rl:add(rectangle)
	rectangle = Rectangle( textcolor, false, btn )
	rl:add(rectangle)

	app.renderList = rl

	for n=1,5 do
		print(n)
		yield()
	end
	runClock = false
end

function collectorTask()
	while true do
		wait(30000)
	    print('taking out the rubbish')
		print(math.floor(collectgarbage('count')) .. ' kb')
		collectgarbage()
	end
end
collectgarbage('generational')
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

font = Font('media/mono.ttf',64)
testtext = app.renderer:textureFromText(font, 'Bu bir testtir!', c);
rectangle = Rectangle(testtext, 210, 50);
app.renderList:add(rectangle)

font = Font('media/font.ttf', 26)

runClock = true
function updateClock()
	local color = Color(0x13,0x45,0x8a,0xff)
	local startTexture <close> = app.renderer:textureFromText(font, '', color)
	local clockRect = Rectangle(startTexture, 260, 8)
	app.renderList:add(clockRect)
	while runClock do
		local text = os.date()
		local clockTexture <close> = app.renderer:textureFromText(font, text, color)
		clockRect:setTexture(clockTexture)
		wait(1000)
	end
end

addTask(updateClock)

print( app.renderer)
print( app.renderList)
print( 'main.lua loaded.')
