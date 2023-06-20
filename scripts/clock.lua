require 'misc'

runClock = true
clockJitter = false
clockRenderList = RenderList()
clockHeight = 24
function updateClock()
	print('starting clock')
	local font <close> = Font('media/pirulen.otf', 20)
	local color = Color 'fe0a4a'
	local clockRect <close> = Rectangle(color, false, {0, app.height - font.lineHeight, 0, 0})
	clockRenderList:add(clockRect)
	local prevtext
	while runClock do
		local text = os.date('  %A %I:%M %p - %B %d %Y')
		if prevtext ~= text then
			local clockTexture <close> = Texture(font, text, color)
			clockRect.texture = clockTexture
			local x
			if clockJitter then
				x = math.random(0,app.width-clockTexture.width)
			else
				x = 0
			end
			clockRect:setDest({x,app.height-font.lineHeight, 0, 0})

			clockRenderList:shouldRender()
			prevtext = text
		end
		wait(1000)
	end
	print( 'clock stopped')
end

addTask(updateClock,'clock')