require 'misc'

runClock = true
clockJitter = false
clockRenderList = RenderList()
clockHeight = 24

function updateClock()
	print 'starting clock'
	local font <close> = Font('media/mono.ttf', 24)
	local color = Color 'FF3BFE0A'
	local clockRect <close> = Rectangle(color, false, { 0, app.height - font.lineHeight, 0, 0 })
	clockRenderList:add(clockRect)
	local prevtext
	while runClock do
		local text = getClockText()
		if prevtext ~= text then
			local clockTexture <close> = Texture(font, text, color)
			clockRect.texture = clockTexture
			local x
			if clockJitter then
				x = math.random(0, app.width - clockTexture.width)
			else
				x = 0
			end
			clockRect:setDest { x, app.height - font.lineHeight, 0, 0 }

			clockRenderList:shouldRender()
			prevtext = text
		end
		wait(1000)
	end
	print 'clock stopped'
end

local weekdays = {
	Sunday = 'Pazar',
	Monday = 'Pazartesi',
	Tuesday = 'Salı',
	Wednesday = 'Çarşamba',
	Thursday = 'Perşembe',
	Friday = 'Cumā',
	Saturday = 'Cumartesi',
}

local months = {
	January = 'Ocak',
	Febuaray = 'Şubat',
	March = 'Mart',
	April = 'Nisan',
	May = 'Mayıs',
	June = 'Hariran',
	July = 'Temmuz',
	August = 'Ağustos',
	September = 'Eylül',
	October = 'Ekim',
	November = 'Kasım',
	December = 'Aralık',
}

function getClockText()
	local text = os.date '  %A %I:%M %p - %B %d %Y' .. ''
	local minute = os.date '%M'

	if minute % 2 == 0 then return text end

	-- Translate to Türkçe
	for english, turkish in pairs(weekdays) do
		text = text:replace(english, turkish)
	end

	for english, turkish in pairs(months) do
		text = text:replace(english, turkish)
	end

	return text
end

addTask(updateClock, 'clock')
