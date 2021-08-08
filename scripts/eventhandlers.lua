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
