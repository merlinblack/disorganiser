require 'textlog'
require 'eventhandlers'
require 'misc'
require 'testtask'
require 'garbage'
require 'clock'
require 'class'
require 'docker'

require 'gui/screen'

class 'MainScreen' (Screen)

function MainScreen:build()
	Screen.build(self)

	local c = Color(0x92,0xee,0xee,0x20)
	local r = { 0, 0, 800, 480 }
	local rectangle <close> = Rectangle(c, true, r);
	self.renderList:add(rectangle)

	local texture <close> = app.renderer:textureFromFile('media/falcon.png')
	local src = { 0, 0, texture.width, texture.height}
	local scale = 0.65 
	local dest = { 32, 54, math.floor(texture.width*scale), math.floor(texture.height*scale)}
	local rectangle <close> = Rectangle(texture, dest, src)
	self.renderList:add(rectangle)

	local btn = { 590, 390, 140, 70}
	local textcolor = c:clone()
	textcolor.a = 0xff
	self:addButton(btn, 'Çikiş', function() app.shouldStop = true end, textcolor)

	btn[2] = btn[2] - 100
	self:addButton(btn, 'Docker', function() docker:activate() end, textcolor)

	self.renderList:add(clockRenderList)
end

mainScreen = MainScreen()
mainScreen:activate()

print('Version: ' .. app.version)
print('main.lua loaded.')
