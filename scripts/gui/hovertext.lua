require 'gui/widget'

class 'HoverText' (Widget)

function HoverText:init(rect, text, textcolor, color, font, backgroundColor)
	Widget.init(self, rect)
	--- @type RenderList
	self.hoverRenderList = RenderList()
	--- @type RenderList
	self.renderList = RenderList()
	--- @type Font
	self.font = font or Font('media/mono.ttf',24)
	--- @type Color|nil
	self.backgroundColor = backgroundColor

	addTask(function()
		self:setText(text, textcolor)
	end, 'HoverText')

	if color ~= nil then
		self:setColor(color)
	end
end

function HoverText:setText(text, color)
	local frameSize = 5
	if text == '' then
		text = ' '
	end
	self.hoverRenderList:clear()
	local texture <close> = Texture(self.font, text, color)
	local left = math.max(frameSize, self.left - texture.width // 2 - frameSize)
	if left + texture.width + frameSize*2 > app.width then
		left = app.width - texture.width - frameSize*2
	end
	local top = math.max(0, self.top - texture.height - frameSize)
	if self.backgroundColor then
		local rect = growRect({ left, top, texture.width, texture.height }, frameSize)
		local background <close> = Rectangle(self.backgroundColor, true, rect)
		self.hoverRenderList:add(background)
		local frame <close> = Rectangle(color, false, rect)
		self.hoverRenderList:add(frame)
	end
	local textRect <close> = Rectangle(texture, left, top)
	self.hoverRenderList:add(textRect)
end

function HoverText:setColor(color)
	self.renderList:clear()

	--- @type Rectangle
	local rect <close> = Rectangle(color, false, self:getRect())

	self.renderList:add(rect)
	self.renderList:shouldRender()
end

function HoverText:addToScreen(screen)
	screen.renderList:add(self.renderList)
	screen.renderList:shouldRender()
	screen:addChild(self)
end

function HoverText:removeFromScreen(screen)
	app.renderList:remove(self.hoverRenderList)
	screen.renderList:remove(self.renderList)
	screen.renderList:shouldRender()
	screen:removeChild(self)
end

function HoverText:mouseMoved( time, x, y, button )
    if self:intersects( x, y ) then
        self.hasMouse = true
		app.renderList:add(self.hoverRenderList)
		app.renderList:shouldRender()
    else
        if self.hasMouse then
			app.renderList:remove(self.hoverRenderList)
			app.renderList:shouldRender()
            self:lostMouse()
        end
    end
end
