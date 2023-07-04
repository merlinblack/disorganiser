#ifndef __LB_COLOR_H
#define __LB_COLOR_H

#include "LuaBinding.h"
#include <SDL2/SDL.h>
#include <sstream>
#include <string>
#include <array>

struct ColorBinding : public ManualBind::PODBinding<ColorBinding, SDL_Color>
{
    static constexpr const char *class_name = "Color";

    static ManualBind::bind_properties *properties()
    {
        static ManualBind::bind_properties properties[] = {
            {"r", get, set},
            {"g", get, set},
            {"b", get, set},
            {"a", get, set},
            {nullptr, nullptr, nullptr}};
        return properties;
    }

    static luaL_Reg *members()
    {
        static luaL_Reg members[] = {
            {"__tostring", toString},
            {"clone", clone},
            {nullptr, nullptr}};
        return members;
    }

    static int create(lua_State *L)
    {
        if (lua_type(L, 1) == LUA_TNUMBER)
            return createFromIntegers(L);

        if (lua_type(L, 1) == LUA_TSTRING)
            return createFromString(L);

        return luaL_error(L, "Don't know how to make a color from parameters given.");
    }

    static int createFromIntegers(lua_State *L)
    {
        Uint8 r, g, b, a;

        r = luaL_checkinteger(L, 1);
        g = luaL_checkinteger(L, 2);
        b = luaL_checkinteger(L, 3);
        a = luaL_checkinteger(L, 4);

        SDL_Color c = {r, g, b, a};

        push(L, c);

        return 1;
    }

    static int createFromString(lua_State *L)
    {
        std::string hexcodes = luaL_checkstring(L, 1);

        int digitsPerElement;
        bool hasAlpha = false;

        switch (hexcodes.length())
        {
        case 4:
            hasAlpha = true;
            // fallthrough
        case 3:
            digitsPerElement = 1;
            break;
        case 8:
            hasAlpha = true;
            // fallthrough
        case 6:
            digitsPerElement = 2;
            break;
        default:
            return luaL_error(L, "hex code must be 8, 6, 4, or 3 digits long");
        }

        std::array<Uint8, 4> elements;
        auto digit = hexcodes.cbegin();
        int index = 0;

        while (digit != hexcodes.cend())
        {
            std::string element;
            int value;

            element.push_back(*digit);

            if (digitsPerElement == 2)
                digit++;

            element.push_back(*digit); // Either next one, or the same one again.

            std::stringstream ss;

            ss << std::hex << element;

            ss >> value;

            if (!ss.good() && !ss.eof())
                return luaL_error(L, "Could not convert hex: '%s'", element.c_str());

            elements[index++] = value;

            digit++;
        }

        if (hasAlpha) {
            SDL_Color c = {elements[1], elements[2], elements[3], elements[0]};
            push(L, c);
        }
        else {
            SDL_Color c = {elements[0], elements[1], elements[2], 255};
            push(L, c);
        }

        return 1;
    }

    static const char *prop_keys[];

    static int get(lua_State *L)
    {
        SDL_Color &c = fromStack(L, 1);

        int which = luaL_checkoption(L, 2, NULL, ColorBinding::prop_keys);

        switch (which)
        {
        case 0:
            lua_pushinteger(L, c.r);
            break;

        case 1:
            lua_pushinteger(L, c.g);
            break;

        case 2:
            lua_pushinteger(L, c.b);
            break;

        case 3:
            lua_pushinteger(L, c.a);
            break;
        }

        return 1;
    }

    static int set(lua_State *L)
    {
        SDL_Color &c = fromStack(L, 1);

        int which = luaL_checkoption(L, 2, NULL, ColorBinding::prop_keys);

        switch (which)
        {
        case 0:
            c.r = luaL_checkinteger(L, 3);
            break;

        case 1:
            c.g = luaL_checkinteger(L, 3);
            break;

        case 2:
            c.b = luaL_checkinteger(L, 3);
            break;

        case 3:
            c.a = luaL_checkinteger(L, 3);
            break;
        }

        return 0;
    }

    static int toString(lua_State *L)
    {
        SDL_Color &c = fromStack(L, 1);
        std::stringstream ss;

        ss << "Color (r:" << (int)c.r << ", g:" << (int)c.g << ", b:" << (int)c.b << ", a:" << (int)c.a << ")";

        lua_pushstring(L, ss.str().c_str());

        return 1;
    }

    static int clone(lua_State *L)
    {
        SDL_Color &orgiinal = fromStack(L, 1);
        SDL_Color clone = orgiinal;
        push(L, clone);
        return 1;
    }
};

#endif //__LB_COLOR_H