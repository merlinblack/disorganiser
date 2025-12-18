require 'misc'
require 'tasks'
require 'gui/gui'
require 'confirmdialog'
require 'quit'
require 'weatherGraphs'
require 'weatherTrends'
require 'garbage'
require 'vader'
require 'main'
require 'main2'
require 'minimenu'
require 'quatro'
require 'systemupdate'
require 'screensaver'
require 'calendar'
require 'ledtouch'

plainprint = print
function print(...)
	plainprint(...)

	if type(telnetOutput) == 'function' then
		local args = table.pack(...)
		for i = 1, args.n do
			telnetOutput(tostring(args[i]))
			if i < args.n then telnetOutput ' ' end
		end
		telnetOutput '\n'
	end
end

require 'console'

print('Version: ' .. app.version)

write('Disorganiser ver: ' .. app.version)
write 'Welcome to the konsole!'

pt(getTasks())

machines = {
	vimes = function()
		mainScreen:activate()

		addTask(function()
			wait(50)
			weatherTrends:buildDataTable(true)
		end, 'initial weather trend build')

		addTask(function()
			wait(10)
			weatherGraphs:buildGraphs(true)
		end, 'initial graph build')
	end,
	threepio = function() miniMenu:activate() end,
	quatro = function()
		quatroDisplay:activate()
		addTask(quatroUpdateTask, 'quatroUpdate')
	end,
}

-- For testing
machines[app.hostname] = machines['quatro']

machines[app.hostname]()

print 'init.lua loaded.'
