require('gui/widget')

class 'InputGroup' (Widget)

function InputGroup:init( rect )
    Widget.init(self, rect)
    self.enabled = true
end

function InputGroup:enable( enabled )
    self.enabled = enabled
end

function InputGroup:mouseMoved( time, x, y, button )
    if self.enabled then
        Widget.mouseMoved( self, time, x, y, button )
    end
end

function InputGroup:mouseClick( time, x, y, button )
    if self.enabled then
        Widget.mouseClick( self, time, x, y, button )
    end
end

function InputGroup:mouseDown( time, x, y, button )
    if self.enabled then
        Widget.mouseDown( self, time, x, y, button )
    end
end

-- Default processing for mouseUp

function InputGroup:keyPressed( keyCode, codepoint )
    if self.enabled then
        Widget.keyPressed( self, keyCode, codepoint )
    end
end

function InputGroup:addButton(rect, captionText, func, textColor, frameColor, backgroundColor, renderList)
    print( 'InputGroup add button', captionText)
	return addButton(self, rect, captionText, func, textColor, frameColor, backgroundColor, renderList)
end
