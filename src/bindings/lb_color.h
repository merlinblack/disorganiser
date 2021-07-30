#ifndef __LB_COLOR_H
#define __LB_COLOR_H

#include "LuaBinding.h"
#include <SDL2/SDL.h>
#include <sstream>

struct ColorBinding: public ManualBind::PODBinding<ColorBinding,SDL_Color>
{
	static constexpr const char* class_name = "Color";

	static ManualBind::bind_properties* properties()
	{
		static ManualBind::bind_properties properties[] = {
			{ "r", get, set },
			{ "g", get, set },
			{ "b", get, set },
			{ "a", get, set },
			{ nullptr, nullptr, nullptr }
		};
		return properties;
	}

    static luaL_Reg* members()
    {
        static luaL_Reg members[] = {
            { "__tostring", toString },
            { nullptr, nullptr }
        };
        return members;
    }

	static int create( lua_State* L )
    {
        Uint8 r, g, b, a;

        r = luaL_checkinteger( L, 1 );
        g = luaL_checkinteger( L, 2 );
        b = luaL_checkinteger( L, 3 );
        a = luaL_checkinteger( L, 4 );

        SDL_Color c = { r, g, b, a };

        push( L, c );

        return 1;
    }

    static const char* prop_keys[];

    static int get( lua_State* L )
    {
        SDL_Color& c = fromStack( L, 1 );

        int which = luaL_checkoption( L, 2, NULL, ColorBinding::prop_keys );

        switch( which )
        {
            case 0:
                lua_pushinteger( L, c.r );
                break;

            case 1:
                lua_pushinteger( L, c.g );
                break;

            case 2:
                lua_pushinteger( L, c.b );
                break;

            case 3:
                lua_pushinteger( L, c.a );
                break;
        }

        return 1;
    }

    static int set( lua_State* L )
    {
        SDL_Color& c = fromStack( L, 1 );

        int which = luaL_checkoption( L, 2, NULL, ColorBinding::prop_keys );

        switch( which )
        {
            case 0:
                c.r = luaL_checkinteger( L, 3 );
                break;

            case 1:
                c.g = luaL_checkinteger( L, 3 );
                break;

            case 2:
                c.b = luaL_checkinteger( L, 3 );
                break;

            case 3:
                c.a = luaL_checkinteger( L, 3 );
                break;
        }

        return 0;
    }

    static int toString( lua_State* L )
    {
        SDL_Color& c = fromStack( L, 1 );
        std::stringstream ss;

        ss << "Color (r:" << (int)c.r << ", g:" << (int)c.g << ", b:" << (int)c.b << ", a:" << (int)c.a << ")";

        lua_pushstring(L, ss.str().c_str());

        return 1;
    }
};

#endif //__LB_COLOR_H