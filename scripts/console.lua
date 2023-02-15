require 'gui/widget'
require 'misc'
require 'run'
require 'history'
require 'autocomplete'

class 'Console' (Widget)

function Console:init()
	Widget.init(self,  {0, 0, app.width, app.height})
	self.renderList = RenderList()
	self.font = Font('media/mono.ttf', 24)
	self.enabled = false
	self.edit = EditString()
	self.currentLine = 0
	self.run = Run()
	self.history = History()
	self:build()
end

function Console:build()
	local backgroundColor = Color '207f2060'
	local frameColor = Color '407f40'
	local cursorColor = Color '0f0'

	self.textColor = Color '80ff00'
	self.topMargin = 5
	self.bottomMargin = 20
	self.leftMargin = 10
	self.rightMargin = 10

	local rectangle <close> = Rectangle(backgroundColor, true, self:getRect())
	self.renderList:add(rectangle)

	local rectangle <close> = Rectangle(frameColor, false, shrinkRect(self:getRect(),1))
	self.renderList:add(rectangle)

	self.emptyline = app.emptyTexture
	self.lineHeight = self.font.lineHeight
	self.charWidth,self.charHeight = self.font:sizeText('X')
	self.charWidth = self.charWidth -1
	self.lineRectangles = {}
	self.nlines = (self.height - self.topMargin - self.bottomMargin) // self.lineHeight

	for i = 1, self.nlines do
		r = Rectangle(
			self.emptyline,
			self.leftMargin, self.topMargin + (i) * self.lineHeight
		)
		r:setClip({0,0,self.width-(self.leftMargin+self.rightMargin),self.lineHeight})
		self.lineRectangles[i]  = r
		self.renderList:add(r)
	end

	self.cursorRectangle = Rectangle(cursorColor, true, {0,0,0,0})
	self.renderList:add(self.cursorRectangle)
end

function Console:isEnabled()
	return self.enabled
end

function Console:toggleEnabled()
	self:setEnabled(not self.enabled)
end

function Console:setEnabled(enabled)
		self.enabled = enabled
		app.textInputMode = enabled
		if enabled then
			app.overlay:add(console.renderList)
		else
			app.overlay:remove(console.renderList)
		end
		app.overlay:shouldRender()
end

function Console:textInput(input)
	if not self.enabled then return end

	self.edit:insert(input)

	self:updateInputDisplay()
end

function Console:keyUp(code, sym)
	--print('Console - key up: ', code, sym)
	if code == 40 then -- enter
		local line = self.edit:getString()
		self.history:insert(line)
		self.edit:clear()
		self:addLine(line)
		self.run:insertLine(line)
		self:updateInputDisplay()
		autoCompleteClear()
	end
	if code == 41 then -- Escape
		self:toggleEnabled()
	end
	if code == 42 then -- Backspace
		if self.edit:index() ~= 0 then
			self.edit:back()
			self.edit:erase()
			self:updateInputDisplay()
		end
	end
	if code == 43 then -- Tab
		self.edit:setString(autoComplete(self.edit:getString()))
		self:updateInputDisplay()
	end
	if code == 74 then -- home
		self.edit:gotoStart()
		self:updateInputDisplay()
	end
	if code == 76 then -- del
		self.edit:erase()
		self:updateInputDisplay()
	end
	if code == 75 then -- PgUp
		self.edit:backWord()
		self:updateInputDisplay()
	end
	if code == 77 then -- end
		self.edit:gotoEnd()
		self:updateInputDisplay()
	end
	if code == 78 then -- PgDn
		self.edit:forwardWord()
		self:updateInputDisplay()
	end
	if code == 79 then -- right arrow
		self.edit:forward()
		self:updateInputDisplay()
	end
	if code == 80 then -- left arrow
		self.edit:back()
		self:updateInputDisplay()
	end
	if code == 81 then -- down arrow
		self.edit:setString(self.history:getNext())
		self:updateInputDisplay()
	end
	if code == 82 then -- up arrow
		self.edit:setString(self.history:getPrevious())
		self:updateInputDisplay()
	end
end

function Console:write(text, addLastNewLine)
	if addLastNewLine == nil then
		addLastNewLine = true
	end

	lines = splitByNewline(text)
	for _,line in pairs(lines) do
		self:addLine(line)
	end
	if addLastNewLine then
		self:addLine("")
	end
end

function Console:addLine(text)

	if self.currentLine == self.nlines then
		for i = 1, self.nlines-1 do
			self.lineRectangles[i].texture = self.lineRectangles[i+1].texture
		end
		self.currentLine = self.currentLine - 1
	end

	self.currentLine = self.currentLine + 1

	if text == '' then
		self.lineRectangles[self.currentLine].texture = self.emptyline
	else
		local max = 60
		local min = 50
		local splitPosition = max

		while true do
			local splitChar = text:sub(splitPosition,splitPosition)
			if splitChar == '' or splitChar == ' ' or splitPosition == min then
				break
			end
			splitPosition = splitPosition - 1
		end

		local remainder = text:sub(splitPosition+1)
		text = text:sub(1,splitPosition)

		local newTexture <close> = app.renderer:textureFromText(self.font, text, self.textColor)
		self.lineRectangles[self.currentLine].texture = newTexture

		if remainder ~= '' then
			self:addLine(remainder)
		end
	end

	self.renderList:shouldRender()
end

function Console:updateInputDisplay()
	text = self.run:getPrompt() .. self.edit:getString()
	--print( 'InputLine: ['.. text ..']')

	line = self.currentLine

	if text == '' then
		self.lineRectangles[line].texture = self.emptyline
	else
		local newTexture <close> = app.renderer:textureFromText(self.font, text, self.textColor)

		self.lineRectangles[line].texture = newTexture
	end

	local pos = self.edit:index() + #self.run:getPrompt()
	self.cursorRectangle:setDest({self.leftMargin + pos * self.charWidth, self.topMargin + line*self.lineHeight, self.charWidth, self.lineHeight})

	self.renderList:shouldRender()
end

function Console:clear()
	for i = 1, self.nlines do
		self.lineRectangles[i].texture = self.emptyline
	end
	self.currentLine = 1
	self:updateInputDisplay()
end

function Console:showHistory()
	wt(self.history.lines)
	write('Current: ' .. self.history.current)
end

function Console:blinkCursor()
	while true do
		self.cursorShown = not self.cursorShown

		if self.cursorShown then
			local pos = self.edit:index() + #self.run:getPrompt()
			self.cursorRectangle:setDest({self.leftMargin + pos * self.charWidth, self.topMargin + (self.currentLine)*self.lineHeight, self.charWidth, self.lineHeight})
		else
			self.cursorRectangle:setDest({0, 0, 0, 0})
		end

		self.renderList:shouldRender()
		wait(450)
	end
end

console = Console()

function write(...)
	print(...)
	local args = table.pack(...)
	local str = ''
	for i = 1, args.n do
		str = str .. ' ' .. args[i]
	end
	str = str:sub(2)
	console:write(str, false)
	console:addLine ""
	console:updateInputDisplay()
end

function clear()
	console:clear()
end

addTask(function() console:blinkCursor() end, "console cursor blink")
