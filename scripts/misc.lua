
function splitByNewline(str)
	str = '' .. str

	lines = {}
	for s in str:gmatch("[^\r\n]+") do
		table.insert(lines, s)
	end
	return lines
end

-- String routines from https://gist.github.com/kgriffs/124aae3ac80eefe57199451b823c24ec
function string:contains(sub)
	return self:find(sub, 1, true) ~= nil
end

function string:startsWith(start)
	return self:sub(1, #start) == start
end

function string:endsWith(ending)
	return ending == "" or self:sub(-#ending) == ending
end

function string:replace(old, new)
    local s = self
    local search_start_idx = 1

    while true do
        local start_idx, end_idx = s:find(old, search_start_idx, true)
        if (not start_idx) then
            break
        end

        local postfix = s:sub(end_idx + 1)
        s = s:sub(1, (start_idx - 1)) .. new .. postfix

        search_start_idx = -1 * postfix:len()
    end

    return s
end

function string:insert(pos, text)
    return self:sub(1, pos - 1) .. text .. self:sub(pos)
end

function pt(t)
	for k,v in pairs(t) do
		print(k,v)
	end
end

function wt(t)
	for k,v in pairs(t) do
		write(k,v)
	end
end

function growRect(rect, amount)
	amount = amount or 1
	return { rect[1] - amount, rect[2] - amount, rect[3] + amount, rect[4] + amount}
end

function shrinkRect(rect, amount)
	amount = amount or 1
	return growRect(rect, -amount)
end

function dirlist(path)
	return io.popen('ls ' .. path):lines()
end

yield = coroutine.yield

function wait(ticks)
	local finish = app.ticks + ticks
	local status = 'sleeping'
	while app.ticks < finish and status ~= 'wakeup' do
		status = yield()
	end
	return status == 'wakeup'
end

function waitForTask(taskName)
	local found  = true
	while found do
		found = false
		local tasks = getTasks()
		for k,v in pairs(tasks) do
			if v == taskName then
				found = true
			end
		end
		local status = yield()
		if status == 'wakeup' then
			found = false
		end
	end
end

function waitForWakeup()
	local status = 'sleeping'
	while status ~= 'wakeup' do
		status = yield()
	end
end

