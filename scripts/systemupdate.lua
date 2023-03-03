require 'clock'
require 'docker'
require 'weather'
require 'unlock'

require 'gui/screen'

class 'SystemUpdate' (Screen)

function SystemUpdate:build()
	Screen.build(self)
	 
	self.fontCode = Font('media/Aurek-Besh.ttf', 18)
	self.font = Font('media/pirulen.otf', 22)

	local texture <close> = app.renderer:textureFromFile('media/falcon.png')
	local src = { 0, 0, texture.width, texture.height}
	local dest = {0, 0, app.width, app.height}
	local rectangle <close> = Rectangle(texture, dest, src)
	self.renderList:add(rectangle)

	local btn = { 10, 5, 180, 70}
	local textcolor = Color 'fff'
	local backcolor = Color '777a'
	
	self:addButton(btn, 'Local', function() self:runTask('rpi','sudo apt update && sudo apt upgrade -y') end, textcolor, nil, backcolor)

	btn[2] = btn[2] + 80
	self:addButton(btn, 'Octavo', function() self:runTask('octavo','sudo dnf update -y') end, textcolor, nil, backcolor)

	btn[2] = btn[2] + 80
	self:addButton(btn, 'ModelB', function() self:runTask('modelb','sudo apt update && sudo apt upgrade -y') end, textcolor, nil, backcolor)

	btn[2] = btn[2] + 80
	self:addButton(btn, 'Vader', function() self:runTask('vader', 'sudo dnf update -y') end, textcolor, nil, backcolor)

	local title <close> = app.renderer:textureFromText(self.fontCode, 'System Update', Color('0f0') )
	local static <close> = Rectangle(title, { app.width-title.width-30, 5,0,0})
	self.renderList:add(static)

	self.renderList:add(clockRenderList)
	self.renderList:shouldRender()
end

function SystemUpdate:swipe(direction)
	if direction == Swipe.Right then
		unlock:activate()
	end
	if direction == Swipe.Left then
		mainScreen:activate()
	end
end

function SystemUpdate:runTask(host, command)
	if self.alreadyRunning then return end
	
	self.alreadyRunning = true

	function task()
		local renderList = RenderList()
		local font <close> = Font('media/mono.ttf',14)
		local tl = TextLog(
			renderList, 
			210, 50,
			Color '00f4',
			Color 'fff',
			font, 
			app.width - 210 - 20, 22)

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
	addTask(task, 'runSystemTask')
end

systemUpdate = SystemUpdate()
