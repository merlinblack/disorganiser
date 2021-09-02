require 'gui/screen'
require 'clock'

class 'ScreenSaver' (Screen)

function ScreenSaver:build()
	Screen.build(self)

	local texture <close> = app.renderer:textureFromFile('media/picture.jpg')
	local src = { 0, 0, texture.width, texture.height}
	local dest = { 0, 0, 800, 480}
	local rectangle <close> = Rectangle(texture, dest, src);
	self.renderList:add(rectangle)

	local btn = { 590, 390, 140, 70}
	local textcolor = Color(0xff,0x45,0x8a,0xff)
	local backcolor = Color(0xff,0x45,0x8a,0x30)
	self:addButton(btn, 'Exit', function() app.shouldStop = true end, textcolor, nil, backcolor)

	self.renderList:add(clockRenderList)
end

screenSaver = ScreenSaver()

function screenSaveTask()

	wait(1000)

	screenSaver:activate()

	for n=1,5 do
		print(n)
		yield()
	end

	collectgarbage()

end
