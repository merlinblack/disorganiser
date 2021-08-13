require 'misc'

function tailtest()
	wait(1000)
	local font <close> = Font('media/mono.ttf',12)
	local tl = TextLog(
		app.renderList, 
		51, 51, 
		Color(0, 0, 0xff, 0x80),
		Color(0xff, 0xff, 0x00, 0xff),
		font, 
		500, 10)

	pt(tl.bounds)
	pt(growRect(tl.bounds))

	local frame <close> = Rectangle(Color(0,0,0xff,0xff), false, growRect(tl.bounds))
	app.renderList:add(frame)

	tl:add('tail test')
	tl:add('---------')

	local proc <close> = ProcessReader()
	proc:add('tail')
	proc:add('-f')
	proc:add('somelog')
	proc:open()
	local more = true
	local results
	while more and not stopTailTest do
		more, results = proc:read()
		results = string.gsub(results, '^%s*(.-)%s*$', '%1')

		if results ~= '' then
			split = splitByNewline(results)
			for i,v in ipairs(split) do
				tl:add(v)
			end
		end
		yield()
	end
	wait(2000)
	tl:destroy()
	app.renderList:remove(frame)
end

stopTailTest = false

addTask(tailtest)

