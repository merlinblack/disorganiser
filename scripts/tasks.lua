
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

function addUniqueTask(taskFunc, taskName)
	if not taskName or taskName == '' then
		error('task name is required for addUniqueTask')
	end
	local found = false
	for idx, name in ipairs(getTasks()) do
		if name == taskName then
			found = true
			break
		end
	end

	if found == false then
		addTask(taskFunc, taskName)
	end
end

function startPrintTasks()
	stopPrintTasks = false
	addTask(function() while not stopPrintTasks do pt(getTasks()) wait(1000) end end, 'print tasks')
end
