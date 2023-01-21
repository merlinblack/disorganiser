dofile (os.getenv('HOME')..'/.config/disorganiser/config.lua')

require 'garbage'
require 'vader'
require 'main'
require 'screensaver'
require 'console'

mainScreen:activate()

print('Version: ' .. app.version)
pt(getTasks())
print('init.lua loaded.')

write("Disorganiser ver: " .. app.version)
write("Welcome to the konsole!")
