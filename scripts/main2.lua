require 'clock'
require 'docker'
require 'weather'
require 'unlock'
require 'ping'

require 'gui/screen'

class 'MainScreen2' (Screen)

function MainScreen2:build()
	Screen.build(self)

	self.lastOctavoCheck = -math.huge
	 
	local offline = Color 'fe0a4a'
	local online = Color '0f0'
	local grey = Color '777'

	self.fontCode = Font('media/Aurek-Besh.ttf', 18)
	self.font = Font('media/pirulen.otf', 22)

	self.offlineTexture = Texture(self.font, 'Offline', offline)
	self.onlineTexture = Texture(self.font, 'Online', online)

	local texture <close> = Texture('media/vader.jpg')
	local src = { 0, 0, texture.width, texture.height}
	local dest = {0, 0, app.width, app.height}
	local rectangle <close> = Rectangle(texture, dest, src)
	self.renderList:add(rectangle)

	local btn = { 30, 150, 180, 110}
	local textcolor = Color 'fe0a4a'
	local backcolor = textcolor:clone()
	backcolor.a = 0x20
	self:addButton(btn, 'System\nUpdate', function() systemUpdate:activate() end, textcolor, nil, backcolor)

	btn[1] = btn[1] + 200
	self.wakeNBakeBtn = self:addButton(btn, 'Detecting\nStatus', function() end, grey, textcolor, backcolor)

	btn[2] = btn[2] + 140
	self.wakeBtn = self:addButton(btn, 'Detecting\nStatus', function() end, grey, textcolor, backcolor)

	btn[1] = btn[1] - 200
	self.retryBtn = self:addButton(btn, 'Retry\nWeather', function(self) self.parent:runTask('localhost', 'cd ~/prog/MS8607/ && pwd && ./retry_api.py') end, grey, textcolor, backcolor)

	self:addButton({app.width-105, app.height-clockHeight-70, 100, 60}, 'Geri', function() mainScreen:activate() end, textcolor, nil, backcolor)

	local static <close> = Rectangle(Texture(self.fontCode, 'Main Screen Two', textcolor ), { 30,5,0,0})
	self.renderList:add(static)

	local static <close> = Rectangle(Texture(self.font, 'Octavo Status', textcolor ), { 30,50,0,0})
	self.renderList:add(static)
	local static <close> = Rectangle(Texture(self.font, 'PING:               HTTPD:', textcolor ), { 30, 80,0,0})
	self.renderList:add(static)

	self.octavoPingStatus = Rectangle(self.offlineTexture, { 120,80,0,0})
	self.octavoHttpdStatus = Rectangle(self.offlineTexture, { 390,80,0,0})
	self.renderList:add(self.octavoPingStatus)
	self.renderList:add(self.octavoHttpdStatus)

	function self:updateAction()
		readLocalWeather()

		if weather.valid == false then
			self.octavoHttpdStatus.texture = self.offlineTexture
		else
			self.octavoHttpdStatus.texture = self.onlineTexture
		end

		if self.lastOctavoCheck + 1000 < app.ticks then
			self.octavoPing = ping(ipaddr.octavo)
		end

		if self.octavoPing then
			self.octavoPingStatus.texture = self.onlineTexture
		else
			self.octavoPingStatus.texture = self.offlineTexture
		end

		self.renderList:shouldRender()
	end

	function self.wakeBtn:updateAction()
		local enabled = false

		if self.parent.octavoPing == false then
			enabled = true
		end

		if self.prev ~= enabled then
			self.prev = enabled
			if enabled then
				self:setCaption('Wake up\nOctavo', online)
				self:setAction(function() self.parent:runTask('localhost','wakeonlan f8:0f:41:ba:c1:63') end)
			else
				self:setCaption('Poweroff\nOctavo', textcolor)
				self:setAction(function() self.parent:runTask('octavo.local', 'sudo poweroff') end)
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

	function self.wakeNBakeBtn:updateAction()
		local enabled = false

		if self.parent.octavoPing == false then
			if self.parent.waitingForOctavo ~= true then
				enabled = true
			else
				-- Don't update caption yet - wakeNBake function has already
				self.prev = enabled
			end
		end

		if self.prev ~= enabled then
			self.prev = enabled
			if enabled then
				self:setCaption('Wake N\nBake', online)
				self:setAction(function() self.parent:wakeNBake() end)
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
	if direction == Swipe.Down then
		console:setEnabled(true)
	end
	if direction == Swipe.Up then
		console:setEnabled(false)
	end
end

function MainScreen2:wakeNBake()
	local offline = Color 'fe0a4a'
	self.waitingForOctavo = true
	waitForTask(self:runTask('localhost','wakeonlan f8:0f:41:ba:c1:63'))
	self.wakeNBakeBtn:setCaption('Waiting...', offline)
	self.wakeNBakeBtn:setAction(function() end)
	self.renderList:shouldRender()
	waitForTask(addTask(function() while weather.valid == false do wait(200) end end))
	self:runTask('localhost', 'cd ~/prog/MS8607/ && pwd && ./retry_api.py')
	self.waitingForOctavo = false
	self.wakeNBakeBtn.prev = nil
end

function MainScreen2:runTask(host, command)
	if self.alreadyRunning then return end
	
	self.alreadyRunning = true

	function task()
		local renderList = RenderList()
		local font <close> = Font('media/mono.ttf',18)
		local tl = TextLog(
			renderList, 
			420, 150,
			Color '400f',
			Color '0ff',
			font, 
			app.width - 420 - 10, 250)

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
