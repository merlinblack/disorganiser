runClock = true
function updateClock()
	local font <close> = Font('media/font.ttf', 26)
	local color = Color(0xfe,0x0a,0x4a,0xff)
	local clockRect <close> = Rectangle(color, false, {0, 480 - font.lineHeight, 0, 0})
	app.renderList:add(clockRect)
	while runClock do
		local text = os.date()
		local clockTexture <close> = app.renderer:textureFromText(font, text, color)
		clockRect.texture = clockTexture
		app.shouldRender = true
		wait(1000*60)
	end
end

addTask(updateClock)
