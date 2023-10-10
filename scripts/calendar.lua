require 'gui/screen'

--[[
    Appointments format:
    {
        {
        year = -1,  -- repeating
        month = -1,
        day = 15,
        title = 'Payday',
        color = 'FFFFEA00'
        },
        ...
        ...
        ...
    }
]]

appointments = require'appointments'

local text = {
    appointments = 'Randevular ve etkinlikler',
    calendar = 'Takvim',
    monday = 'Pazartesi',
    tuesday = 'Salı',
    wednesday = 'Çarşamba',
    thursday = 'Perşembe',
    friday = 'Cumā',
    saturday = 'Cumartesi',
    sunday = 'Pazar',
    mon = 'Pz',
    tue = 'Sa',
    wed = 'Cr',
    thu = 'Pr',
    fri = 'Cu',
    sat = 'Ct',
    sun = 'Pa',
    today = 'bugün',
    previous = 'öncesi',
    next = 'sonraki',
}
text.weekdays = { text.monday, text.tuesday, text.wednesday, text.thursday, text.friday, text.saturday, text.sunday }
text.weekdaysShort = { text.mon, text.tue, text.wed, text.thu, text.fri, text.sat, text.sun }
text.months = { 
    'Ocak', -- January
    'Şubat', -- Febuaray
    'Mart', -- March
    'Nisan', -- April
    'Mayıs', -- May
    'Hariran', -- June
    'Temmuz', -- July
    'Ağustos', -- August
    'Eylül', -- September
    'Ekim', -- October
    'Kasım', -- November
    'Aralık' -- December
}

local daysInMonth = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

class 'Calendar' (Screen)

function Calendar:init()
    self:setStandardFont()
    self:setDate()
    self.font2 = Font('media/mono.ttf', 24)
    self.font3 = Font('media/font.ttf', 18)
    self.text = text
    self.portrait = app.width < app.height
    self:buildTextTextures()
    self:calcAppointments()

    self.calendarRenderList = RenderList()
    Screen.init(self)

    self.renderList:add(self.calendarRenderList)


    local titleTex <close> = Texture(self.font, text.calendar, Color 'fff')
    local title <close> = Rectangle(titleTex, (app.width // 2) - (titleTex.width // 2), 5 )
    self.renderList:add(title)

    local titleTex <close> = Texture(self.font2, text.appointments, Color 'fff')
    local x, y = (3 * app.width // 4) - (titleTex.width // 2), 34
    if self.portrait then
        x = 20
        y = (app.height // 2) - 35
    end
    local title <close> = Rectangle(titleTex, x, y )
    self.renderList:add(title)

    local x = 20
    for i,v in pairs(self.text.weekdaysShort) do
        local texture = self.textures[v]
        local rectangle <close> = Rectangle(texture, x, 74)
        local hovertext = HoverText({x, 74, texture.width, texture.height}, self.text.weekdays[i], Color 'fff', nil, nil, Color 'ff0000ff')
        hovertext:addToScreen(self)
        hovertext.renderList:add(rectangle)
        x = x + 50
    end

    local buttonTop = app.height - 50 - clockHeight
    self:addButton({  0, buttonTop, 140, 50}, text.previous, function() self:previous() end, Color 'ffffffff')
    self:addButton({145, buttonTop, 150, 50}, text.today, function() self:today() end, Color 'ffffffff')
    self:addButton({300, buttonTop, 165, 50}, text.next, function() self:next() end, Color 'ffffffff')
    self:addButton({app.width - 120, buttonTop, 115, 50}, 'Geri', function() self:activatePrevious() end, Color 'ffffffff')
    self.renderList:add(clockRenderList)
end

function Calendar:setDate(year, month)
    local today = os.date('*t')
    local dateShown
    if year and month then
        dateShown = os.date('*t', os.time{year = year, month = month, day = 1})
    else
        dateShown = os.date('*t', os.time{year = today.year, month = today.month, day = 1})
    end
    self.year = dateShown.year
    self.month = dateShown.month
    self.day = dateShown.day
    self.firstWeekday = dateShown.wday
    self.currentYear = today.year
    self.currentMonth = today.month
    self.currentDay = today.day
end

function Calendar:calcAppointments()
    -- Reoccuring appointments get set to the 'next' occurance
    local calculated = {}
    for _,v in pairs(appointments) do
        -- deep copy
        local n = {}
        for k,v2 in pairs(v) do
            n[k] = v2
        end
        if n.month == -1 then
            n.month = self.month
            if n.day < self.currentDay and self.currentMonth == self.month then
                n.month = (n.month % 12) + 1
            end
        end
        if n.year == -1 then
            n.year = self.year
            if n.month < self.month then
                n.year = n.year + 1
            end
        end
        n.timestamp = os.time(n)
        table.insert(calculated, n)
    end
    table.sort(calculated, function( a, b ) return a.timestamp < b.timestamp end)
    self.appointments = calculated
end

function Calendar:buildTextTextures()
    self.textures = {}
    for _,v in pairs(self.text) do
        if type(v) == 'string' then
            self.textures[v] = Texture(self.font2, v, Color'fff')
        end
    end
    for i = 1, 31 do
        self.textures[i] = Texture(self.font2, string.format('%2d',i), Color'fff')
    end
end

function Calendar:today()
    self:setDate()
    self:calcAppointments()
    self:build()
end

function Calendar:previous()
    self:setDate(self.year, self.month - 1)
    self:calcAppointments()
    self:build()
end

function Calendar:next()
    self:setDate(self.year, self.month + 1)
    self:calcAppointments()
    self:build()
end

function Calendar:build()

    self.calendarRenderList:clear()

    local titleTex <close> = Texture(self.font2, text.months[self.month] .. ' ' .. self.year, Color 'fff')
    local title <close> = Rectangle(titleTex, (app.width // 4) - (titleTex.width // 2), 34 )
    self.calendarRenderList:add(title)

    self:buildMonthDays()
    self:buildAppointments()

    self.calendarRenderList:shouldRender()
end

function Calendar:buildMonthDays()
    if self:isLeapYear() then
        daysInMonth[2] = 29
    else
        daysInMonth[2] = 28
    end

    local renderList <close> = RenderList()
    local y = 110
    local margin = 40
    local weekDay = self.firstWeekday

    -- Adjust to Turkish style, Monday first, Sunday last
    weekDay = ((weekDay + 5) % 7) + 1

    for day = 1, daysInMonth[self.month] do
        local texture = self.textures[day]
        local x = margin + ((weekDay-1) * 50) - texture.width
        local colorForDate = self:getColorForDate(self.year, self.month, day)
        if colorForDate then
            texture = Texture(self.font2, string.format('%2d', day), colorForDate)
            local x = margin + ((weekDay-1) * 50) - 30
            local frame <close> = Rectangle(colorForDate, false, { x, y, 32, 32 })
            renderList:add(frame)
        end
        local rectangle <close> = Rectangle(texture, x, y)
        renderList:add(rectangle)
        weekDay = weekDay + 1
        if weekDay > 7 then
            weekDay = 1
            y = y + 50
        end
    end
    self.calendarRenderList:add(renderList)
end

function Calendar:buildAppointments()
    local start = os.time { year = self.year, month = self.month, day = 1 }
    local limit = start + 60*60*24*60 -- 60 days
    local x = (app.width // 2) + 20
    local y = 74
    local right_column = x
    if self.portrait then 
        x = 20
        y = app.height // 2
        right_column = app.width // 2
    end
    local max = 4

    for _, appointment in pairs(self.appointments) do
        if appointment.timestamp > start and appointment.timestamp < limit then
            
            local wday = os.date('*t', appointment.timestamp).wday
            
            local texture <close> = Texture(self.font3, appointment.title, Color(appointment.color))
            local rectangle <close> = Rectangle(texture, x, y)
            self.calendarRenderList:add(rectangle)
            if not self.portrait then
                y = y + self.font3.lineHeight + 1
            end
            
            local texture <close> = Texture(self.font3, 
                string.format('%s %d%s %s', 
                    text.weekdays[wday],
                    appointment.day, 
                    ordinalSuffix(appointment.day),
                    text.months[appointment.month]
                ),
                Color(appointment.color)
            )
            local rectangle <close> = Rectangle(texture, right_column, y)
            self.calendarRenderList:add(rectangle)
            y = y + self.font3.lineHeight + 5
            max = max - 1
        end
        if max == 0 then
            break
        end
    end
end

function Calendar:getColorForDate(year, month, day)
    if day == self.currentDay and year == self.currentYear and month == self.currentMonth then
        return Color 'ff00ff00'
    end
    local timestamp = os.time{year = year, month = month, day = day}

    for _,appointment in pairs(self.appointments) do
        if timestamp == appointment.timestamp then
            return Color(appointment.color)
        end
    end

    return nil
end

function Calendar:getStartWeekdayForMonth()
    local date = {
        year = self.year,
        month = self.month,
        day = 1
    }
    return os.date('*t', os.time(date)).wday
end

function Calendar:isLeapYear()
    return self.year % 4 == 0 and (self.year % 100 ~= 0 or self.year % 400 == 0)
end

function Calendar:swipe(direction)
	if direction == Swipe.Right then
		self:previous()
	end
	if direction == Swipe.Left then
        self:next()
	end
	if direction == Swipe.Down then
		console:setEnabled(true)
	end
	if direction == Swipe.Up then
		console:setEnabled(false)
	end
end

calendar = Calendar()

addTask(
    function()
        while wait(60000) ~= 'killed' do
            if calendar.month == calendar.currentMonth and calendar.year == calendar.currentYear then
                if calendar.currentDay ~= os.date('*t').day then
                    calendar:today()
                end
            end
        end
    end,
    'calendar'
)
