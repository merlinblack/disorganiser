-- Lua Class
--
-- Creates a class definition to have members added to
--
-- Example use:
--
-- class 'base'
--
-- function base:__init()       -- will be called on construction
--   self.xyz = 42
-- end
--
-- class 'derived' (base)       -- will inherit base's members unless overridden
--
-- function derived:something( x )
--   self.xyz = x
--   self.abc = 'Hello World'
-- end
--
-- d=derived()
-- d:something()
-- print( d.xyz, d.abc )
--


function class( name )
    _G[name] = {
        __type = name,
        __luaclass = true
    }

    local newclass = _G[name]

    local metatable =
    {
        __call = function(...)
            local obj = {}

            setmetatable( obj,
            {
                __index = newclass,
                __gc = function( self )
                    if self.destroy then
                        self:destroy()
                    end
                end
            } )

            if obj.init ~= nil then
                obj:init( select(2, ...) )
            end

            return obj
        end
    }

    setmetatable( newclass, metatable )

    return function( base ) metatable['__index'] = base newclass['__base'] = base end
end


--- Return true if the 'instance' is of type 'cls' or a base is of type 'cls'
function instanceOf(instance, cls)

    if type(cls) == 'table' then
        cls = cls.__type
        if cls == nil then
            error('Invalid class given to instanceOf')
        end
    end

    if instance.__type == cls then
        return true
    end

    if instance.__base then
        return instanceOf(instance.__base, cls)
    end

    return false

end
