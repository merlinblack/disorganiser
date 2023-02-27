function quit()
	addTask(
		function()
			if confirm('Quit Disorganiser?') then
				app.shouldStop = true
			end
		end,
		'quit'
	)
end

function restart()
	addTask(
		function()
			if confirm('Restart Disorganiser?') then
				app.shouldRestart = true
				app.shouldStop = true
			end
		end,
		'quit'
	)
end