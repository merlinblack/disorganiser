require 'class'
require 'misc'

class 'TextLog'

function TextLog:init(renderList, x, y, backgroundColor, color, font, width, nlines)
    bounds = { x, y, width, nlines * font.lineHeight }
    pt(bounds)
    self.renderList = renderList
    self.font = font
    self.color = color
    self.nlines = nlines
    self.background = Rectangle(backgroundColor, true, bounds )
    self.emptyline = app.renderer:textureFromText(font, ' ', color)
    print(self.emptyline)
    self.lineRectangles = {}

    renderList:add(self.background)
    for i = 1, nlines do
        r = Rectangle(
            self.emptyline, 
            x, y + (i-1) * font.lineHeight
        )
        r:setClip({0,0,width,font.lineHeight})
        self.lineRectangles[i]  = r
        print(i, r)
        renderList:add(r)
    end

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
    app.shouldRender = true
end

function TextLog:shutdown()
    self.renderList:remove(self.background)
    for i = 1, self.nlines do
        self.renderList:remove(self.lineRectangles[i])
    end
    print('TextLog shutdown')
    self.hasShutdown = true
end

function TextLog:destroy()
    if not self.hasShutdown then
        self:shutdown()
    end
end
