function collectorTask()
	while true do
		wait(60000)
		print(math.floor(collectgarbage 'count') .. ' kb')
		collectgarbage()
	end
end
collectgarbage 'generational'
addTask(collectorTask, 'garbage')
