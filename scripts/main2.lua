require 'clock'
require 'docker'
require 'weather'
require 'unlock'

require 'gui/screen'

class 'MainScreen2' (Screen)

function MainScreen2:build()
	Screen.build(self)
	 
	local offline = Color 'fe0a4a'
	local online = Color '0f0'
	local grey = Color '777'

	self.fontCode = Font('media/Aurek-Besh.ttf', 18)
	self.font = Font('media/pirulen.otf', 22)

	self.offlineTexture = app.renderer:textureFromText(self.font, 'Offline', offline)
	self.onlineTexture = app.renderer:textureFromText(self.font, 'Online', online)

	local texture <close> = app.renderer:textureFromFile('media/vader.jpg')
	local src = { 0, 0, texture.width, texture.height}
	local dest = {0, 0, app.width, app.height}
	local rectangle <close> = Rectangle(texture, dest, src)
	self.renderList:add(rectangle)

	local btn = { 30, 100, 180, 110}
	local textcolor = Color 'fe0a4a'
	local backcolor = textcolor:clone()
	backcolor.a = 0x20
	self:addButton(btn, 'System\nUpdate', function() systemUpdate:activate() end, textcolor, nil, backcolor)

	btn[1] = btn[1] + 200
	--self:addButton(btn, 'ModelB\nUpdate', function() self:runTask('modelb.local','sudo apt update && sudo apt upgrade -y') end, textcolor, nil, backcolor)
	self.wakeNBake = self:addButton(btn, 'Detecting\nStatus', function() end, grey, textcolor, backcolor)

	btn[2] = btn[2] + 140
	self.wakeBtn = self:addButton(btn, 'Detecting\nStatus', function() end, grey, textcolor, backcolor)

	btn[1] = btn[1] - 200
	self.retryBtn = self:addButton(btn, 'Retry\nWeather', function() self:runTask('localhost', 'cd ~/prog/MS8607/ && pwd && ./retry_api.py') end, grey, textcolor, backcolor)

	local static <close> = Rectangle(app.renderer:textureFromText(self.fontCode, 'Main Screen Two', textcolor ), { 30,5,0,0})
	self.renderList:add(static)

	local static <close> = Rectangle(app.renderer:textureFromText(self.font, 'Octavo Status:', textcolor ), { 30,50,0,0})
	self.renderList:add(static)

	self.octavoStatus = Rectangle(self.offlineTexture, { 320,50,0,0})
	self.renderList:add(self.octavoStatus)

	function self:updateAction()
		readLocalWeather()
		if weather.valid == false then
			self.octavoStatus.texture = self.offlineTexture
		else
			self.octavoStatus.texture = self.onlineTexture
		end
		self.renderList:shouldRender()
	end

	function self.wakeBtn:updateAction()
		local enabled = false

		if weather.valid == false then
			enabled = true
		end

		if self.prev ~= enabled then
			self.prev = enabled
			if enabled then
				self:setCaption('Wake up\nOctavo', online)
				self:setAction(function() mainScreen2:runTask('localhost','wakeonlan f8:0f:41:ba:c1:63') end)
			else
				self:setCaption('Poweroff\nOctavo', textcolor)
				self:setAction(function() mainScreen2:runTask('octavo', 'sudo poweroff') end)
			end
		end

	end

	function self.retryBtn:updateAction()
		local enabled = false

		if weather.valid == true then
			if fileExists('~/prog/MS8607/measurements.db') then
				print('got measurements')
				enabled = true
			end
			if fileExists('~/prog/MS8607/retry.db') then
				print('got retry db')
				enabled = true
			end
		end

		if self.prev ~= enabled then
			self.prev = enabled
			if enabled then
				self:setCaption('Retry\nWeather', online)
			else
				self:setCaption('Retry\nWeather', grey)
			end
		end

	end

	function self.wakeNBake:updateAction()
		local enabled = false

		if weather.valid == false then
			if mainScreen2.waitingForOctavo ~= true then
				enabled = true
			end
		end

		if self.prev ~= enabled then
			self.prev = enabled
			if enabled then
				self:setCaption('Wake N\nBake', online)
				self:setAction(function() mainScreen2:wakeNBake() end)
			else
				self:setCaption('Wake N\nBake', grey)
				self:setAction(function() end)
			end
		end
	end
	
	self.renderList:add(clockRenderList)
	self.renderList:shouldRender()
end

function MainScreen2:update()
	if (self.updateCountDown or 0) < 1 then
		self.updateCountDown = 5
		Screen.update(self)
	else
		self.updateCountDown = self.updateCountDown - 1
	end
end

function MainScreen2:swipe(direction)
	if direction == Swipe.Right then
		mainScreen:activate()
	end
	if direction == Swipe.Left then
		unlock:activate()
	end
end

function MainScreen2:wakeNBake()
	self.waitingForOctavo = true
	waitForTask(self:runTask('localhost','wakeonlan f8:0f:41:ba:c1:63'))
	self.wakeNBake:setCaption('Waiting...', offline)
	self.renderList:shouldRender()
	waitForTask(addTask(function() while weather.valid == false do wait(200) end end))
	self:runTask('localhost', 'cd ~/prog/MS8607/ && pwd && ./retry_api.py')
	self.waitingForOctavo = false
end

function MainScreen2:runTask(host, command)
	if self.alreadyRunning then return end
	
	self.alreadyRunning = true

	function task()
		local renderList = RenderList()
		local font <close> = Font('media/mono.ttf',14)
		local tl = TextLog(
			renderList, 
			420, 100,
			Color '00f4',
			Color '0ff',
			font, 
			app.width - 420 - 10, app.height - clockHeight - 100)

		local frame <close> = Rectangle(Color('00f'), false, growRect(tl.bounds))

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

		tl:add('host: ' .. host)
		tl:add(command)

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
	return addTask(task, 'runSystemTask-main2')
end

mainScreen2 = MainScreen2()
