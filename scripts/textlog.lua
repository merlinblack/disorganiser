require 'class'
require 'misc'

class 'TextLog'

function TextLog:init(renderList, x, y, backgroundColor, color, font, width, nlines)
    local lineHeight = math.floor(font.lineHeight * 1.2)
    self.bounds = { x, y, width, (nlines+2) * lineHeight }
    self.renderList = renderList
    self.font = font
    self.color = color
    self.nlines = nlines
    self.background = Rectangle(backgroundColor, true, self.bounds )
    self.emptyline = app.emptyTexture
    self.lineRectangles = {}

    -- using lineHeight as left and right margins also
    renderList:add(self.background)
    for i = 1, nlines do
        r = Rectangle(
            self.emptyline, 
            x + lineHeight, y + (i) * lineHeight
        )
        r:setClip({0,0,width-(2*lineHeight),lineHeight})
        self.lineRectangles[i]  = r
        renderList:add(r)
    end

    renderList:shouldRender()

    print( 'TextLog init finished')
end

function TextLog:add(text)
    for i = 1, self.nlines-1 do
        self.lineRectangles[i].texture = self.lineRectangles[i+1].texture
    end
    if text == '' then
        self.lineRectangles[self.nlines].texture = self.emptyline
    else
        local newTexture <close> = app.renderer:textureFromText(self.font, text, self.color)
        self.lineRectangles[self.nlines].texture = newTexture
    end
    self.renderList:shouldRender()
end

function TextLog:shutdown()
    self.renderList:remove(self.background)
    for i = 1, self.nlines do
        self.renderList:remove(self.lineRectangles[i])
    end
    self.renderList:shouldRender()
    self.hasShutdown = true
    print('TextLog shutdown')
end

function TextLog:destroy()
    if not self.hasShutdown then
        self:shutdown()
    end
end
