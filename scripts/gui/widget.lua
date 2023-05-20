require 'class'

class 'Widget'

function Widget:init( rect )
    self.children = {}
    self.left   = rect[1]
    self.top    = rect[2]
    self.width  = rect[3]
    self.height = rect[4]
end

-- Can be called, directly or by garbage collection
-- if garbage collection runs it, it must not error!!
function Widget:destroy()
    if type(self.children) == 'table' then
        for _,child in pairs(self.children) do
            child:destroy()
        end
    end
end

function Widget:intersects( x, y )
    --print('intersects', x, y, self.left, self.top, self.width, self.height)
    if x < self.left then
        return false
    end
    if y < self.top then
        return false
    end
    if x > self.left + self.width then
        return false
    end
    if y > self.top + self.height then
        return false
    end
    return true
end

function Widget:mouseMoved( time, x, y, button )
    if self:intersects( x, y ) then
        self.hasMouse = true
        for _,child in pairs(self.children) do
            if child.mouseMoved then child:mouseMoved( time, x, y, button ) end
        end
    else
        if self.hasMouse then
            self:lostMouse()
        end
    end
end

function Widget:mouseClick( time, x, y, button )
    if self:intersects( x, y ) then
        for _,child in pairs(self.children) do
            if child.mouseMoved then
                local handled = child:mouseClick( time, x, y, button )
                if handled then
                    return true
                end
            end
        end
    end
end

function Widget:mouseDown( time, x, y, button )
    if self:intersects( x, y ) then
        for _,child in pairs(self.children) do
            if child.mouseMoved then child:mouseDown( time, x, y, button ) end
        end
    end
end

function Widget:mouseUp( time, x, y, button )
    if self:intersects( x, y ) then
        for _,child in pairs(self.children) do
            if child.mouseMoved then child:mouseUp( time, x, y, button ) end
        end
    end
end

function Widget:keyPressed( keyCode, codepoint )
    for _,child in pairs(self.children) do
        child:keyPressed( keyCode, codepoint )
    end
end

function Widget:addChild( widget )
    table.insert(self.children, widget)
end

function Widget:removeChild( widget )
    local index = table.getIndex(self.children, widget)
    if index > 0 then
        table.remove(self.children, index)
    end
end

-- Return true to cancel move, when it would move off view
function Widget:move( x, y )
    local left = self.left
    local top = self.top
    local width = self.width
    local height = self.height

    if left + x < 0 or top + y < 0 then return true end
    if left + width + x > info.width or top + height + y > info.height then
        return true
    end

    self.left = self.left + x
    self.top = self.top + y

    for _,child in pairs( self.children ) do
        if child.move then child:move( x, y ) end
    end
end

function Widget:lostMouse()
    self.hasMouse = false
    for _,child in pairs( self.children ) do
        if child.lostMouse then child:lostMouse() end
    end
end

function Widget:getRect()
    return {self.left, self.top, self.width, self.height}
end

function Widget:update()
    if type(self.updateAction) == 'function' then
        self:updateAction()
    end

    for _,child in pairs( self.children ) do
        child:update()
    end
end
