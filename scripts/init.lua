require 'misc'
cfg = os.getenv('HOME')..'/.config/disorganiser/config.lua'
if not fileReadable(cfg) then
	app.shouldStop = true
	print('Configuration file does not exist.')
	return
else
	dofile (cfg)
end

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

function animate()
	wait(20)
	local spriteTexture1 <close> = app.renderer:textureFromFile('media/increasing.png')
	local spriteTexture2 <close> = app.renderer:textureFromFile('media/decreasing.png')
	local sprites = {}
	local n = 4000
	local speed = 10
	for i=1,n do
		local sprite 
		if i%2 == 0 then
			sprite = Rectangle(spriteTexture1,{0,0,0,0})
		else
			sprite = Rectangle(spriteTexture2,{0,0,0,0})
		end
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

	for x=0, 150 do
		for i=1,n do
			local sprite = sprites[i]
			sprite.x = sprite.x + sprite.dx
			sprite.y = sprite.y + sprite.dy
			sprite.rect:setDest{sprite.x, sprite.y, 0,0}
		end
		app.renderList:shouldRender()
		wait(1)
	end

	for x=0, 150 do
		for i=1,n do
			local sprite = sprites[i]
			sprite.x = sprite.x - sprite.dx
			sprite.y = sprite.y - sprite.dy
			sprite.rect:setDest{sprite.x, sprite.y, 0,0}
		end
		app.renderList:shouldRender()
		wait(1)
	end

	for i=1,n do
		app.renderList:remove(sprites[i].rect)
		app.renderList:shouldRender()
		if i%100 == 0 then
			wait(1)
		end
	end

end

function lc(command)
	local proc <close> = ProcessReader()

	proc:set('bash')
	proc:add('-c')
	proc:add(command)
	proc:open()

	local more = true
	local results
	while more do
		more, results = proc:read()
		results = string.gsub(results, '^%s*(.-)%s*$', '%1')

		if results ~= '' then
			write(results)
		end
		yield()
	end
end

function aslan()
	local birthdate = {
		year = 2023,
		month = 2,
		day = 11,
		hour = 11,
		min = 21
	}
	local birthdateTS = os.time(birthdate)
	local now = os.time()
	local diff = os.difftime(now, birthdateTS)

	write('Seconds:\t' .. string.format('%.0d', diff))
	write('Days:\t\t'  .. string.format('%.2f', diff / (24*60*60)))
	write('Weeks:\t\t' .. string.format('%.1f', diff / (24*60*60*7)))

	write('10,000,000 (10 million) seconds on: ' .. os.date('%c', birthdateTS+10000000))
end

print('init.lua loaded.')