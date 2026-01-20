require 'misc'

clockchimes = true

function clockChimesTask()
	while clockchimes do
		local seconds = tonumber(os.date '%S')
		local minutes = tonumber(os.date '%M')
		local hour = tonumber(os.date '%H')

		--print(hour, minutes, seconds)

		if seconds == 0 then
			if hour == 12 and minutes == 0 then
				play 'ticktokstrike.mp3'
			else
				if hour > 6 and hour < 22 then
					if minutes == 0 or minutes == 30 then play 'dingdong.mp3' end
				end
			end
		end
		wait(1000)
	end
end

addTask(clockChimesTask, 'clockChimes')
