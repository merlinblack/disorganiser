dofile (os.getenv('HOME')..'/.config/disorganiser/config.lua')
lanes = require('lanes').configure()

require 'tasks'
require 'confirmdialog'
require 'quit'
require 'weatherGraphs'
require 'weatherTrends'
require 'garbage'
require 'vader'
require 'main'
require 'main2'
require 'systemupdate'
require 'screensaver'
require 'console'

mainScreen:activate()

print('Version: ' .. app.version)

write("Disorganiser ver: " .. app.version)
write("Welcome to the konsole!")

pt(getTasks())

print('init.lua loaded.')