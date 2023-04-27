function quit()
	addTask(
		function()
			if confirm('Disorganiserden çık?') then
				app.shouldStop = true
			end
		end,
		'quit'
	)
end

function restart()
	addTask(
		function()
			if confirm('Takrar Başlat?') then
				app.shouldRestart = true
				app.shouldStop = true
			end
		end,
		'quit'
	)
end