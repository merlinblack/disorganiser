yield = coroutine.yield

function wait(ticks)
	local finish = app.ticks + ticks
	local status = 'sleeping'
	while app.ticks < finish and status ~= 'wakeup' and status ~= 'killed' do
		status = yield()
	end
	local over = app.ticks - finish
	if over > 500 then
		print('Task: ' .. getCurrentTaskName() .. ' overslept by: ' .. over)
		pt(getTasks())
	end
	return status
end

function waitSeconds(seconds)
	local finish = os.time() + seconds
	local status = 'sleeping'
	while os.time() < finish and status ~= 'wakeup' and status ~= 'killed' do
		status = yield()
	end
	return status
end

function yieldEveryN(count, N)
	count = count + 1
	if count >= N then
		yield()
		return 0
	end

	return count
end

function waitForTask(taskName)
	if getCurrentTaskName() == taskName then error 'Task can not wait for itself.' end
	local running = true
	while running do
		running = isTaskRunning(taskName)
		local status = yield()
		if status == 'wakeup' or status == 'killed' then return status end
	end
end

function waitForWakeup()
	local status = 'sleeping'
	while status ~= 'wakeup' and status ~= 'killed' do
		status = yield()
	end
end

function isTaskRunning(taskName)
	for _, name in ipairs(getTasks()) do
		if name == taskName then return true end
	end
	return false
end

function addUniqueTask(taskFunc, taskName)
	if not taskName or taskName == '' then error 'task name is required for addUniqueTask' end

	if not isTaskRunning(taskName) then addTask(taskFunc, taskName) end
end

function startPrintTasks()
	stopPrintTasks = false
	addTask(function()
		while not stopPrintTasks do
			pt(getTasks())
			wait(1000)
		end
	end, 'print tasks')
end
