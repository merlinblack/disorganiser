require 'gui/widget'

class 'HoverText' (Widget)

function HoverText:init(rect, text, textcolor, color, font)
	Widget.init(self, rect)
	self.hoverRenderList = RenderList()
	self.renderList = RenderList()
	self.font = font or Font('media/mono.ttf',24)
	addTask(function()
		self:setText(text, textcolor)
	end, 'HoverText')
	self:setColor(color)
end

function HoverText:setText(text, color)
	if text == '' then
		text = ' '
	end
	self.hoverRenderList:clear()
	local texture <close> = Texture(self.font, text, color)
	local rect <close> = Rectangle(texture, self.left - texture.width // 2, self.top - texture.height)
	self.hoverRenderList:add(rect)
end

function HoverText:setColor(color)
	self.renderList:clear()

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
