require 'misc'

doubleTab = doubleTab or {}

keywords = keywords or valuesToKeys { 
    'and',       'break',     'do',        'else',      'elseif',    'end',
    'false',     'for',       'function',  'goto',      'if',        'in',
    'local',     'nil',       'not',       'or',        'repeat',    'return',
    'then',      'true',      'until',     'while',
 }

function autoComplete( str )
    local prefixend = string.find( str:reverse(), '[() %[%]=+/,%%]' )
    local prefix = ''
    local possibles

    if prefixend then
        prefix = string.sub( str, 1, #str - prefixend + 1 )
        str = string.sub( str, #str - prefixend + 2 )
    end

    str, possibles = complete(str)

    if #possibles > 1 then
        if doubleTab.str == str then
            write( table.unpack( possibles ) )
        else
            doubleTab.str = str
        end
    end

    return prefix..str
end

function autoCompleteClear()
    doubleTab.str = nil
end

function complete( str )
    local possibles = getCompletions( keywords, str )
    for k,v in pairs( getCompletions( _G, str ) ) do
        table.insert( possibles, v )
    end
    if #possibles > 0 then
        str = string.sub( possibles[1], 1, getIdenticalPrefixLength( possibles, #str ) )
    end
    return str, possibles
end

function getCompletions( where, str )
    local g = where
    local ret = {}
    local dotpos = string.find( str:reverse(), '[%.:]' )
    local prefix = ''
    local dottype = ''

    if dotpos ~= nil then
        dotpos = #str - dotpos
        prefix = string.sub( str, 1, dotpos )
        dottype = string.sub( str, dotpos + 1, dotpos + 1 )
        g = getTable( where, prefix)
        str = string.sub( str, dotpos + 2 )
    end

    if g == nil then
        return {}
    end

    if type( g ) == 'table' then
        for k,v in pairs(g) do
            if string.find( k, str ) == 1 and string.sub(k,1,1) ~= '_' then
                table.insert( ret, prefix .. dottype .. k )
            end
        end
        if g.__luaclass then
            for k, v in pairs( getLuaClassMembers( g ) ) do
                if string.find( v, str ) == 1 then
                    table.insert( ret, prefix .. dottype .. v )
                end
            end
        end
    else
        -- Retrieve class info if any
        for k,v in pairs( getClassInfo( g ) ) do
            if string.find( v, str ) == 1 then
                table.insert( ret, prefix .. dottype .. v )
            end
        end

    end

    return ret
end

function getTable( where, tblname )
    --print( 'Looking up:', tblname, where )
    local lastdot = string.find( tblname:reverse(), '%.' )
    --print( 'Lastdot',  lastdot )
    if lastdot == nil then
        return where[tblname]
    end
    local prefix = string.sub( tblname, 1, #tblname - lastdot )
    local tbl = getTable( where, prefix )
    local subscript = string.sub( tblname, #tblname - string.find( tblname:reverse(), '%.' ) + 2 )
    --print( "Subscript:", subscript, tblname, where )
    if tbl then
        return tbl[subscript]
    else
        return nil
    end
end

function getIdenticalPrefixLength( tbl, start )
    if #tbl == 0 then return start end
    local l = start
    local str
    local allSame = true
    while allSame == true do
        if l > #tbl[1] then return #tbl[1] end
        str = string.sub( tbl[1], 1, l )
        for k, v in pairs( tbl ) do
            if string.find( v, str ) ~= 1 then
                allSame = false
            end
        end
        l = l + 1
    end
    return l - 2
end

function getClassInfo( cls )
    local ret = {}
    local mt = getmetatable( cls )
    if mt then
        for k, v in pairs( mt ) do
            if string.sub( k, 1, 1 ) ~= '_' then
                table.insert( ret, k )
            end
        end
        if mt.__properties then
            for k, v in pairs( mt.__properties ) do
                if string.sub( k, 1, 1 ) ~= '_' then
                    table.insert( ret, k )
                end
            end
        end
    end

    return ret
end

function getLuaClassMembers( cls )
    local ret = {}
    if cls.__base then
        ret = getLuaClassMembers(cls.__base)
    end
    for k, _ in pairs( cls ) do
        if string.sub( k, 1, 1 ) ~= '_' then
            table.insertOnce( ret, k )
        end
    end
    return ret
end

