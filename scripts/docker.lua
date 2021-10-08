require 'gui/screen'
require 'textlog'

class 'Docker' (Screen)

function Docker:build()
	--Screen.build(self)
	self.font = Font('media/pirulen.otf',16)
	local rectangle <close> = Rectangle(Color(0,0,0,0), true, {0, 0, app.width, app.height})
	self.renderList:add(rectangle)
	local background <close> = app.renderer:textureFromFile('media/docker.png')
	local src = {0, 0, background.width, background.height}
	local dest = {40, 60, background.width//2, background.height//2}
	local rectangle <close> = Rectangle(background, dest, src)
	self.renderList:add(rectangle)

	local btn = {620, 350, 140, 100}
	local textcolor = Color(0xff,0x45,0x8a,0xff)
	local backcolor = Color(0xff,0x45,0x8a,0x30)

	self:addButton(btn, 'geri', function() mainScreen:activate() end, textcolor, nil, backcolor)
	btn[2] = btn[2] - 120

	self:addButton(btn, 'durdur', function() self:durdur() end, textcolor, nil, backcolor)
	btn[2] = btn[2] - 104

	self:addButton(btn, 'products', function() self:start('products') end, textcolor, nil, backcolor)
	btn[2] = btn[2] - 104
	
	self:addButton(btn, 'orders', function() self:start('orders') end, textcolor, nil, backcolor)
	btn[1] = btn[1] - 144
	
	self:addButton(btn, 'auth', function() self:start('auth') end, textcolor, nil, backcolor)
	btn[2] = btn[2] + 104

	self:addButton(btn, 'dynamo', function() self:start('dynamo') end, textcolor, nil, backcolor)
	btn[2] = btn[2] + 104

	self:addButton(btn, 'hq', function() self:start('hq') end, textcolor, nil, backcolor)
	
	self.renderList:add(clockRenderList)
end

function Docker:durdur()
	self:runOnVader('durdur 2>&1')
end

function Docker:start(what)
	prog = 'durdur 2>&1;başlat ' .. what .. ' 2>&1'
	self:runOnVader(prog)
end

function Docker:runOnVader(prog)
	if self.alreadyRunning then return end
	
	self.alreadyRunning = true

	function task()
		local renderList = RenderList()
		local font <close> = Font('media/mono.ttf',14)
		local tl = TextLog(
			renderList, 
			11, 24,
			Color(0xff, 0, 0xff, 0x40),
			Color(0xff, 0xff, 0xff, 0xff),
			font, 
			430, 20)

		local frame <close> = Rectangle(Color(0xff,0,0xff,0xff), false, growRect(tl.bounds))

		renderList:add(frame)

		self.renderList:add(renderList)

		local proc <close> = ProcessReader()
		proc:set('ssh')
		proc:add('vader')
		proc:add(prog)
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
		tl:add('')
		tl:add('FINISHED')
		wait(2500)
		tl:destroy()
		self.renderList:remove(renderList)
		self.renderList:shouldRender()
		self.alreadyRunning = false
	end
	addTask(task)
end

docker = Docker()
