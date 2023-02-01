dofile (os.getenv('HOME')..'/.config/disorganiser/config.lua')
lanes = require('lanes').configure()

require 'weatherGraphs'
require 'weatherTrends'
require 'garbage'
require 'vader'
require 'main'
require 'screensaver'
require 'console'

mainScreen:activate()

print('Version: ' .. app.version)

write("Disorganiser ver: " .. app.version)
write("Welcome to the konsole!")

pt(getTasks())

print('init.lua loaded.')