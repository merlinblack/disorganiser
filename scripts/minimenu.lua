require 'gui/screen'

class 'MiniMenu'(Screen)

function MiniMenu:init()
	self.fontBig = Font('media/pirulen.otf', 48)
	self.font = Font('media/pirulen.otf', 32)

	Screen.init(self)
end

function MiniMenu:build()
	local textcolor = Color '777'
	local framecolor = Color '333'
	local backcolor = Color 'fff'

	local background <close> = Rectangle(Color 'fff', true, { 0, 0, app.width, app.height })
	self.renderList:add(background)

	local title <close> = Texture(self.fontBig, 'Our Pictures', textcolor)
	local titleRect <close> = Rectangle(title, app.width // 2 - title.width // 2, 50)
	self.renderList:add(titleRect)

	local width = 300
	local height = 80
	local btn = { app.width // 2 - width // 2, 150, width, height }

	function nextPos(btn)
		btn[2] = btn[2] + 120
		return btn
	end

	self:addButton(btn, 'Foto', function() startScreenSave() end, textcolor, framecolor, backcolor)
	btn = nextPos(btn)
	self:addButton(btn, 'Hava', function() weatherTrends:activate() end, textcolor, framecolor, backcolor)
	btn = nextPos(btn)
	self:addButton(btn, 'Takvim', function() calendar:activate() end, textcolor, framecolor, backcolor)
	btn = nextPos(btn)
	self:addButton(btn, 'Sistem', function() mainScreen2:activate() end, textcolor, framecolor, backcolor)
	btn = nextPos(btn)
	self:addButton(btn, 'Tekrar\nBaşlat', function() restart() end, textcolor, framecolor, backcolor)
	btn = nextPos(btn)
	self:addButton(btn, 'Çikiş', function() quit() end, textcolor, framecolor, backcolor)
	btn = nextPos(btn)
	self:addButton(btn, 'Kapat', function() poweroff() end, textcolor, framecolor, backcolor)
end

miniMenu = MiniMenu()
