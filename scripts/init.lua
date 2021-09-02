dofile (os.getenv('HOME')..'/.config/disorganiser/config.lua')
require 'garbage'
require 'main'
require 'screensaver'

mainScreen:activate()

function shortlived()
	wait(500)
	pt(getTasks())
	wakeTask('after')
	wait(500)
	print('bye bye')
end

function aftershort()
	waitForTask('byebye')
	print('AfterShort')
end

addTask(shortlived, 'byebye')
addTask(aftershort, 'after')

print('Version: ' .. app.version)
	pt(getTasks())
print('init.lua loaded.')
