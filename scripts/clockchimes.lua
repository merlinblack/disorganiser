require 'misc'

clockchimes = true
clockchimesstop = false
clockchimesvolume = 64

function clockChimesTask()
	while not clockchimesstop do
		if clockchimes then
			local seconds = tonumber(os.date '%S')
			local minutes = tonumber(os.date '%M')
			local hour = tonumber(os.date '%H')

			--print(hour, minutes, seconds)

			if seconds == 0 then
				if hour == 12 and minutes == 0 then
					play('ticktokstrike.mp3', clockchimesvolume)
				else
					if hour > 5 and hour <= 23 then
						if minutes == 0 then play('dingdong.mp3', clockchimesvolume) end
					end
				end
			end
		end
		wait(1000)
	end
end

addTask(clockChimesTask, 'clockChimes')
