require 'class'

class 'Run'

function Run:init()
	self.mainPrompt = '> '
	self.secondaryPrompt = '>> '
	self:reset()
end

function Run:reset()
	self.currentLine = ''
	self.firstLine = true
	self.prompt = self.mainPrompt
end

function Run:insertLine(line)

	if line:startsWith '=' and self.firstLine then
		line = 'return ' .. line:sub(2)
	end

	self.firstLine = false

	self.currentLine = self.currentLine .. ' ' .. line

	func, err = load(self.currentLine)

	print(func, err)

	if func == nil then
		if err:endsWith '<eof>' then
			-- need more input, try adding ()
			func = load(self.currentLine .. '()')

			if func == nil then
				-- nope, indicate more needed
				self.prompt = self.secondaryPrompt
				return
			end
		else
			write(err)
			self:reset()
			return
		end
	end

	self:reset()

	addTask(func,'run')
end

function Run:getPrompt()
	return self.prompt
end