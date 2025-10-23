require("gui/screen")
local json = require("json")

class("QuatroDisplay")(Screen)

function QuatroDisplay:build()
	Screen.build(self)

	self.temperature = 20.0
	self.tvoc = 100
	self.pressure = 1020.0

    self.clockColor = Color("ff7f7f7f");
    local backgroundColor = Color("ff202020")
	local frameColor = Color("2f2f6f2f")
	local backColor = Color("ff1a1a1a")

	self.font = Font("media/mono.ttf", 32)
    self.clockFont = Font("media/digital7.ttf", 256+64)

    local background <close> = Rectangle(backgroundColor, true, { 0, 0, app.width, app.height })
    self.renderList:add(background)

    local clockWidth = 1400
    local clockHeight = 500
    self.clockRect = Rectangle(Texture(self.clockFont, self:getClockText(), self.clockColor), 
        { 
            app.width // 2 - clockWidth // 2, 
            app.height // 2- clockHeight // 2, 
            0, 0
        } 
    )
    self.renderList:add(self.clockRect)

	local spacing = (app.width - (450 * 3)) // 4
    local left = spacing
	local top = app.height - 125

	self.temperatureRect = self:pill(left, top, frameColor, backColor)
    left = left + 450 + spacing

	self.tvocRect = self:pill(left, top, frameColor, backColor)
    left = left + 450 + spacing

	self.pressureRect = self:pill(left, top, frameColor, backColor)
    left = left + 450 + spacing

	self:updateView()
end

function QuatroDisplay:pill(left, top, frameColor, backColor)
	local rrect <close> = RoundedRectangle(frameColor, { left, top, 450, 100 }, 10, backColor)

	local rect = Rectangle(app.emptyTexture, { left + 30, top + 30, 0, 0 })

	self.renderList:add(rrect)
	self.renderList:add(rect)

	return rect
end

function QuatroDisplay:updateClock()
    self.clockRect.texture = Texture(self.clockFont, self:getClockText(), self.clockColor)
    self.renderList:shouldRender()
end

function QuatroDisplay:getClockText()
	local text
    if os.time() % 2 == 0 then
        text = os.date '%I:%M %p' .. ''
    else
        text = os.date '%I %M %p' .. ''
    end
    return text
end

function QuatroDisplay:updateView()
	self.temperatureRect.texture = Texture(self.font, "Temperature: " .. self.temperature .. " °C", textcolor)
	self.tvocRect.texture = Texture(self.font, "TVOC Reading: " .. self.tvoc .. " ppb", textcolor)
	self.pressureRect.texture = Texture(self.font, "Pressure: " .. self.pressure .. " mbar", textcolor)
	self.renderList:shouldRender()
end

function QuatroDisplay:updateData()
	local jsonStr = self:run("mcp9808")
	local data = json.decode(jsonStr)
	self.temperature = data.temperature

	local jsonStr = self:run("ags10_simple")
	local data = json.decode(jsonStr)
	self.tvoc = data.tvoc

	local jsonStr = self:run("bmp280")
	local data = json.decode(jsonStr)
	self.pressure = data.pressure

	self:updateView()
end

function QuatroDisplay:run(program)
	local proc <close> = SubProcess()

	write(program)

	proc:set("ssh")
	proc:add("quatro.local")
	proc:add(program)
	proc:add("--json")
	proc:open()

	local more = true
	local results = ""
	local part = ""
	while more do
		more, part = proc:read()
		part = string.gsub(part, "^%s*(.-)%s*$", "%1")
		results = results .. part
		yield()
	end

	write(results)

	return results
end

quatroDisplay = QuatroDisplay()

function quatroUpdateTask()
    local clock = 0
    local nextDataTime = 0

    while not stopQuatro do
        if clock < os.time() then
            quatroDisplay:updateClock()
            clock = os.time()
        end
        if nextDataTime < os.time() then
            quatroDisplay:updateData()
            nextDataTime = os.time() + 30
        end
        waitSeconds(1)
    end
end
        

