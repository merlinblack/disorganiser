require 'misc'
require 'tasks'
require 'confirmdialog'
require 'quit'
require 'weatherGraphs'
require 'weatherTrends'
require 'garbage'
require 'vader'
require 'main'
require 'main2'
require 'minimenu'
require 'systemupdate'
require 'screensaver'
require 'calendar'
require 'ledtouch'

plainprint = print
function print(...)
	plainprint(...)

	if type(telnetOutput) == 'function' then
		local args = table.pack(...)
		for i = 1, args.n do
			telnetOutput(tostring(args[i]))
			if i < args.n then 
				telnetOutput(' ')
			end
		end
		telnetOutput('\n')
	end
end

require 'console'

if app.isPictureFrame then
	miniMenu:activate()
else
	mainScreen:activate()
end

print('Version: ' .. app.version)

write("Disorganiser ver: " .. app.version)
write("Welcome to the konsole!")

pt(getTasks())

function animate()
	wait(20)
	local spriteTexture1 <close> = Texture('media/increasing.png')
	local spriteTexture2 <close> = Texture('media/decreasing.png')
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
	local proc <close> = SubProcess()

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

function citizenship()
	local date = {
		year = 2023,
		month = 7,
		day = 11,
		hour = 15,
		min = 30
	}
	local dateTS = os.time(date)
	local now = os.time()
	local diff = os.difftime(now,dateTS)

	write('Time since citizenship:')
	write('Secs:\t' .. string.format('%.0d', diff))
	write('Days:\t'  .. string.format('%.2f', diff / (24*60*60)))
	write('Weeks:\t' .. string.format('%.1f', diff / (24*60*60*7)))
	write(' \r')
end

function octavoDropboxStatus()
	local proc <close> = SubProcess()
	proc:set('ssh')
	proc:add('octavo.local')
	proc:add('dropbox')
	proc:add('status')
	proc:open()
	local more = true
	local results
	local combined ='Octavo dropbox status:\n'
	while more do
		wait(1000)
		more, results = proc:read()
		results = string.gsub(results, '^%s*(.-)%s*$', '%1')
		combined = combined .. results
	end
	proc:close()
	write(combined .. '\n ')
end

print('init.lua loaded.')
