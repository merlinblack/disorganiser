function ordinalSuffix(n)
	local i = n % 10
	local j = n % 100

	if i == 1 and j ~= 11 then return 'st' end

	if i == 2 and j ~= 12 then return 'nd' end

	if i == 3 and j ~= 13 then return 'rd' end

	return 'th'
end

function splitByNewline(str)
	str = '' .. str

	lines = {}
	for s in str:gmatch '[^\r\n]+' do
		table.insert(lines, s)
	end
	return lines
end

function table.getIndex(tbl, element)
	for index, value in pairs(tbl) do
		if value == element then return index end
	end
	return 0
end

function table.insertOnce(tbl, element)
	if table.getIndex(tbl, element) ~= 0 then return end
	table.insert(tbl, element)
end

-- String routines from https://gist.github.com/kgriffs/124aae3ac80eefe57199451b823c24ec
function string:contains(sub) return self:find(sub, 1, true) ~= nil end

function string:startsWith(start) return self:sub(1, #start) == start end

function string:endsWith(ending) return ending == '' or self:sub(-#ending) == ending end

function string:replace(old, new)
	local s = self
	local search_start_idx = 1

	while true do
		local start_idx, end_idx = s:find(old, search_start_idx, true)
		if not start_idx then break end

		local postfix = s:sub(end_idx + 1)
		s = s:sub(1, (start_idx - 1)) .. new .. postfix

		search_start_idx = -1 * postfix:len()
	end

	return s
end

function string:replaceFirst(old, new)
	local s = self

	local start_idx, end_idx = s:find(old, 1, true)

	if start_idx then
		local postfix = s:sub(end_idx + 1)
		s = s:sub(1, (start_idx - 1)) .. new .. postfix
	end

	return s
end

function string:tabsToSpaces(tabWidth)
	local tabWidth = tabWidth or 8
	local s = self

	while s:contains '\t' do
		local pos = s:find('\t', 1, true)
		local nextTabStop = ((pos // tabWidth) + 1) * tabWidth
		local spaces = nextTabStop - pos + 1
		s = s:replaceFirst('\t', string.rep(' ', spaces))
	end

	return s
end

function string:insert(pos, text) return self:sub(1, pos - 1) .. text .. self:sub(pos) end

function pt(t)
	for k, v in pairs(t) do
		print(k, v)
	end
end

function wt(t)
	if type(t) ~= 'table' then
		write(tostring(t))
	else
		write(wtt(t))
	end
end

function wtt(t, visited, indent, chain)
	local visited = visited or {}
	local indent = indent or ''
	local chain = chain or ''
	local str = ''
	for k, v in pairs(t) do
		str = str .. indent .. tostring(k) .. ':'
		if type(v) == 'table' and visited[v] == nil then
			visited[v] = chain .. '.' .. k
			str = str .. '\n' .. wtt(v, visited, indent .. '..', visited[v])
		elseif visited[v] ~= nil then
			str = str .. '\tseen ref: ' .. visited[v] .. '\n'
		else
			str = str .. '\t' .. tostring(v) .. '\n'
		end
	end
	return str
end

function growRect(rect, amount)
	amount = amount or 1
	return { rect[1] - amount, rect[2] - amount, rect[3] + 2 * amount, rect[4] + 2 * amount }
end

function shrinkRect(rect, amount)
	amount = amount or 1
	return growRect(rect, -amount)
end

function valuesToKeys(t)
	local r = {}
	for k, v in pairs(t) do
		r[v] = k
	end
	return r
end

function dirList(path) return io.popen('ls ' .. path):lines() end

function fileExists(path)
	local success, retReason, retValue = os.execute('stat ' .. path .. ' > /dev/null 2>&1')

	return retValue == 0
end

function fileReadable(name)
	local f = io.open(name, 'r')
	if f ~= nil then
		f:close()
		return true
	else
		return false
	end
end

function printf(...) print(string.format(...)) end
