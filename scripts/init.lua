dofile (os.getenv('HOME')..'/.config/disorganiser/config.lua')
require 'garbage'
require 'main'

mainScreen:activate()

print('Version: ' .. app.version)
print('init.lua loaded.')
