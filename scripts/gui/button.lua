require 'gui/widget'

class 'Button' (Widget)

function Button:mouseClick( time, x, y, button )
    if self:intersects( x, y ) then
        if Widget.mouseClick( self, time, x, y, button ) then
            return true
        end
        if self.action then
            return self:action( time, x, y, button )
        end
    end
end

function Button:setAction(func)
    self.action = func
end