require 'gui/widget'

class 'HoverText' (Widget)

function HoverText:init(rect, text, textcolor, color, font)
	Widget.init(self, rect)
	--- @type RenderList
	self.hoverRenderList = RenderList()
	--- @type RenderList
	self.renderList = RenderList()
	--- @type Font
	self.font = font or Font('media/mono.ttf',24)

	addTask(function()
		self:setText(text, textcolor)
	end, 'HoverText')

	if color ~= nil then
		self:setColor(color)
	end
end

function HoverText:setText(text, color)
	if text == '' then
		text = ' '
	end
	self.hoverRenderList:clear()
	--- @type Texture
	local texture <close> = Texture(self.font, text, color)
	local left = math.max(0, self.left - texture.width // 2)
	if left + texture.width > app.width then
		left = app.width - texture.width
	end
	local top = math.max(0, self.top - texture.height)
	--- @type Rectangle
	local rect <close> = Rectangle(texture, left, top)
	self.hoverRenderList:add(rect)
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
