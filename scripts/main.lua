require 'events'
require 'eventnames'
require 'textlog'
require 'eventhandlers'
require 'misc'
require 'makebutton'
require 'testtask'
require 'garbage'
require 'clock'
require 'sshtasktest'
require 'tailtest'

-- these can get garbage collected when we are done with main.lua
local rectange
local texture
local testtext

c = Color(0x92,0xee,0xee,0x20)
print(c)
r = { 0, 0, 800, 480 }
rectangle = Rectangle(c, true, r);
print(rectangle)
app.renderList:add(rectangle)

texture = app.renderer:textureFromFile('media/falcon.png')
local src = { 0, 0, texture.width, texture.height}
local scale = 0.65 
local dest = { 32, 54, math.floor(texture.width*scale), math.floor(texture.height*scale)}
rectangle = Rectangle(texture, dest, src)
app.renderList:add(rectangle)

local btn = { ExitBtn.x1, ExitBtn.y1, ExitBtn.x2-ExitBtn.x1, ExitBtn.y2-ExitBtn.y1}
textcolor = c:clone()
textcolor.a = 0xff
makeButton(app.renderList, textcolor, btn, 'Çikiş')

font = Font('media/mono.ttf',64)
testtext = app.renderer:textureFromText(font, 'Bu bir testtir!', c);
rectangle = Rectangle(testtext, 210, 50);
app.renderList:add(rectangle)

app.renderList:shouldRender()

print( app.renderer)
print( app.renderList)
print( 'main.lua loaded.')
