require 'suspend'
require 'ping'
-- Periodically test if Vader is running

vaderAlive = true

function checkVaderTask()
	if app.isPictureFrame then return end
	wait(10)
	while true do
		vaderAlive = ping(ipaddr.vader)
		if not vaderAlive then suspend:activate() end
		wait(5 * 60000)
	end
end

if app.hostname == 'vimes' then addTask(checkVaderTask, 'vaderCheck') end
