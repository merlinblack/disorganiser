require 'class'

class 'History'

function History:init()
	self.lines = {}
	self.current = 0
	self.max = 1000
end

function History:insert(line)
	-- Check if line is already there, and remove if so...
	for index,value in ipairs(self.lines) do
		if value == line then 
			table.remove(self.lines, index)
			break -- there will only ever be one at most
		end
	end
	
	table.insert(self.lines, line)

	-- enforce max lines
	if #self.lines > self.max then
		table.remove(self.lines, 1)
	end

	self.current = #self.lines

end

function History:getPrevious()
	if #self.lines == 0 then
		return ''
	end

	if self.current > 1 then
		self.current = self.current - 1
	else
		self.current = #self.lines
	end

	return self.lines[self.current]
end

function History:getNext()
	if #self.lines == 0 then
		return ''
	end

	if self.current == #self.lines then
		self.current = 1
	else
		self.current = self.current + 1
	end

	return self.lines[self.current]
end