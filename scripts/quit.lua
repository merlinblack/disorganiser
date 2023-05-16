function quit()
	quitting = true
	addTask(
		function()
			if confirm('Disorganiserden çık?') then
				app.shouldStop = true
			end
			quitting = nil
		end,
		'quit'
	)
end

function restart()
	quitting = true
	addTask(
		function()
			if confirm('Takrar Başlat?') then
				app.shouldRestart = true
				app.shouldStop = true
			end
			quitting = nil
		end,
		'quit'
	)
end