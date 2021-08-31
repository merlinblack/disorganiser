require 'misc'

runClock = true
clockRenderList = RenderList()
function updateClock()
	print('starting clock')
	local font <close> = Font('media/font.ttf', 22)
	local color = Color(0xfe,0x0a,0x4a,0xff)
	local clockRect <close> = Rectangle(color, false, {0, 480 - font.lineHeight, 0, 0})
	clockRenderList:add(clockRect)
	while runClock do
		local text = os.date('  %A %I:%M %p - %B %d %Y')
		local clockTexture <close> = app.renderer:textureFromText(font, text, color)
		clockRect.texture = clockTexture
		clockRenderList:shouldRender()
		wait(1000*60)
	end
	print( 'clock stopped')
end

addTask(updateClock)
