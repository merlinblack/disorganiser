require 'misc'

function startAuth()
	wait(1500)
	local font <close> = Font('media/mono.ttf',12)
	local tl = TextLog(
		app.renderList, 
		51, 51,
		Color(0xff, 0, 0xff, 0x80),
		Color(0xff, 0xff, 0x00, 0xff),
		font, 
		500, 10)

	pt(tl.bounds)
	pt(growRect(tl.bounds))

	local frame <close> = Rectangle(Color(0xff,0,0xff,0xff), false, growRect(tl.bounds))
	app.renderList:add(frame)

	tl:add('başlat auth on vader')
	tl:add('')

	local proc <close> = ProcessReader()
	proc:add('ssh')
	proc:add('vader')
	proc:add('başlat auth 2>&1; durdur 2>&1')
	proc:open()
	local more = true
	local results
	while more do
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
	print( 'Finished startAuth')
end

--addTask(startAuth)

