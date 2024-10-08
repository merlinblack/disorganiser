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

function remoterestart()
	app.shouldRestart = true
	app.shouldStop = true
end

function poweroff()
	quiting = true
	if app.disablePoweroff == true then
		addTask(
			function()
				confirm('Poweroff is disabled')
				quitting = nil
			end,
			'poweroff'
		)
	else
		addTask(
			function()
				if confirm('Gerçekten güç kapalı?') then
					print 'Turning the power off'
					local process = SubProcess()
					process:set('sudo')
					process:add('poweroff')
					process:open()
					local more = true
					local output
					while more do
						more, output = process:read()
						print(output)
					end
					process:close()
				end
				quitting = nil
			end,
			'poweroff'
		)
	end
end