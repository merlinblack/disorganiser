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

function animate()
	local spriteTexture <close> = app.renderer:textureFromFile('media/increasing.png')
	local sprites = {}
	local n = 4000
	local speed = 10
	for i=1,n do
		local sprite = Rectangle(spriteTexture,{0,0,0,0})
		sprites[i] = {
			rect= sprite,
			x= math.random(0,app.width),
			y= math.random(0,app.height),
			dx= math.random(-speed,speed),
			dy= math.random(-speed,speed),
		}
		if sprites[i].dx == 0 and sprites[i].dy == 0 then
			sprites[i].dx = math.random(1,speed)
		end
		app.renderList:add(sprite)
	end

	for x=0, 1000 do
		for i=1,n do
			local sprite = sprites[i]
			sprite.x = sprite.x + sprite.dx
			sprite.y = sprite.y + sprite.dy
			sprite.rect:setDest{sprite.x, sprite.y, 0,0}
		end
		app.renderList:shouldRender()
		wait(1)
	end

	for i=1,n do
		app.renderList:remove(sprites[i].rect)
	end

	app.renderList:shouldRender()
end