dofile (os.getenv('HOME')..'/.config/disorganiser/config.lua')

require 'garbage'
require 'vader'
require 'main'
require 'screensaver'

mainScreen:activate()

print('Version: ' .. app.version)
pt(getTasks())
print('init.lua loaded.')
