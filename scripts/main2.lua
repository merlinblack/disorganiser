require 'clock'
require 'docker'
require 'weather'
require 'unlock'

require 'gui/screen'

class 'MainScreen2' (Screen)

function MainScreen2:build()
	Screen.build(self)
	 
	local offline = Color(0xfe,0x0a,0x4a,0xff)
	local online = Color(0x00, 0xff, 0x00, 0xff)

	self.fontCode = Font('media/Aurek-Besh.ttf', 18)
	self.font = Font('media/pirulen.otf', 22)

	self.offlineTexture = app.renderer:textureFromText(self.font, 'Offline', offline)
	self.onlineTexture = app.renderer:textureFromText(self.font, 'Online', online)

	local texture <close> = app.renderer:textureFromFile('media/vader.jpg')
	local src = { 0, 0, texture.width, texture.height}
	local dest = {0, 0, app.width, app.height}
	local rectangle <close> = Rectangle(texture, dest, src)
	self.renderList:add(rectangle)

	local btn = { 30, 100, 160, 110}
	local textcolor = Color(0xfe,0x0a,0x4a,0xff)
	local backcolor = textcolor:clone()
	backcolor.a = 0x20
	self:addButton(btn, 'System\nUpdate', function() self:runTask('localhost','sudo apt update && sudo apt upgrade -y') end, textcolor, nil, backcolor)

	btn[1] = btn[1] + 180
	self:addButton(btn, 'ModelB\nUpdate', function() self:runTask('modelb.local','sudo apt update && sudo apt upgrade -y') end, textcolor, nil, backcolor)

	btn[1] = btn[1] - 180
	btn[2] = btn[2] + 140
	self:addButton(btn, 'Retry\nWeather', function() self:runTask('localhost', 'cd ~/prog/MS8607/ && pwd && ./retry_api.py') end, textcolor, nil, backcolor)

	local static <close> = Rectangle(app.renderer:textureFromText(self.fontCode, 'Main Screen Two', textcolor ), { 30,5,0,0})
	self.renderList:add(static)

	local static <close> = Rectangle(app.renderer:textureFromText(self.font, 'Octavo Status:', textcolor ), { 30,50,0,0})
	self.renderList:add(static)

	self.octavoStatus = Rectangle(self.offlineTexture, { 320,50,0,0})
	self.renderList:add(self.octavoStatus)

	self.stopOctavoUpdate = false
	function updateOctavoStatus()
		while self.stopOctavoUpdate == false do
			if self:isActive() then
				readLocalWeather()
				if weather == nil or weather.valid == false then
					self.octavoStatus.texture = self.offlineTexture
				else
					self.octavoStatus.texture = self.onlineTexture
				end
				self.renderList:shouldRender()
			end
			wait(5000)
		end
	end

	addTask(updateOctavoStatus, 'octavoStatus')
	
	self.renderList:add(clockRenderList)
	self.renderList:shouldRender()
end

function MainScreen2:swipe(direction)
	if direction == Swipe.Right then
		mainScreen:activate()
	end
end

function MainScreen2:runTask(host, command)
	if self.alreadyRunning then return end
	
	self.alreadyRunning = true

	function task()
		local renderList = RenderList()
		local font <close> = Font('media/mono.ttf',14)
		local tl = TextLog(
			renderList, 
			380, 100,
			Color(0x0, 0, 0xff, 0x40),
			Color(0x0, 0xff, 0xff, 0xff),
			font, 
			410, 20)

		local frame <close> = Rectangle(Color(0xff,0,0xff,0xff), false, growRect(tl.bounds))

		renderList:add(frame)

		self.renderList:add(renderList)

		local proc <close> = ProcessReader()

		if host ~= 'localhost' then
			proc:set('ssh')
			proc:add(host)
		else
			proc:set('bash')
			proc:add('-c')
		end
		proc:add(command)
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
	addTask(task, 'runSystemTask')
end

mainScreen2 = MainScreen2()
