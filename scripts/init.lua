dofile (os.getenv('HOME')..'/.config/disorganiser/config.lua')
require 'garbage'
require 'main'
require 'screensaver'

mainScreen:activate()

print('Version: ' .. app.version)
print('init.lua loaded.')
