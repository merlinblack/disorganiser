#ifndef __LB_ROUNDED_RECTANGLE_H
#define __LB_ROUNDED_RECTANGLE_H

#include "LuaBinding.h"
#include "LuaRef.h"
#include "bindings.h"
#include "rounded_rectangle.h"
#include "lb_renderlist.h"
#include "lb_color.h"
#include <sstream>

struct RoundedRectangleBinding : public ManualBind::Binding<RoundedRectangleBinding,RoundedRectangle>
{
	static constexpr const char* class_name = "RoundedRectangle";

	static luaL_Reg* members()
	{
		static luaL_Reg members[] = {
			{ "__upcast", upcast },
			{ "__tostring", tostring },
			{ "setDest", setDest },
			{ "setColor", setColor },
			{ "setFill", setFill },
			{ "setRadius", setRadius },
			{ nullptr, nullptr }
		};
		return members;
	}

	static int create(lua_State *L)
	{
		using ManualBind::LuaRef;

		SDL_Color &color = ColorBinding::fromStack(L, 1);
		SDL_Rect dest = getRectFromTable(L, 2);
		int radius = lua_tointeger(L, 3);

		if (lua_isnoneornil( L, 4))
		{
			RoundedRectanglePtr rectangle = std::make_shared<RoundedRectangle>(color, dest, radius);

			push(L, rectangle);
			return 1;
		}

		SDL_Color &fillColor = ColorBinding::fromStack(L, 4);

		RoundedRectanglePtr rectangle = std::make_shared<RoundedRectangle>(color, dest, radius, fillColor);

		push(L, rectangle);

		return 1;
	}

	static int upcast( lua_State *L )
	{
		RoundedRectanglePtr p = fromStack( L, 1 );

		RenderablePtr rp = std::dynamic_pointer_cast<Renderable>( p );

		RenderableBinding::push( L, rp );

		return 1;
	}

	static int tostring( lua_State* L )
	{
		RoundedRectanglePtr r = fromStack( L, 1 );
		std::stringstream ss;

		ss << "Rounded Rectangle: " << std::hex << r.get() << std::dec;
		ss << " dest: { ";
		SDL_Rect rect = r->getDest();
		ss << rect.x << ", " << rect.y << ", " << rect.w << ", " << rect.h;
		ss << "}";

		lua_pushstring( L, ss.str().c_str() );

		return 1;
	}

	static int setDest( lua_State* L )
	{
		RoundedRectanglePtr p = fromStack( L, 1 );
		SDL_Rect r = getRectFromTable( L, 2 );

		p->setDest(r);
		return 0;
	}

	static int setColor( lua_State* L )
	{
		RoundedRectanglePtr p = fromStack( L, 1 );
		SDL_Color& c = ColorBinding::fromStack( L, 2 );

		p->setColor(c);
		return 0;
	}

	static int setFill( lua_State* L )
	{
		RoundedRectanglePtr p = fromStack( L, 1 );
		bool fill = lua_toboolean( L, 2 );

		p->setFill(fill);
		return 0;
	}

	static int setRadius( lua_State* L )
	{
		RoundedRectanglePtr p = fromStack( L, 1 );
		int radius = lua_tointeger( L, 2 );

		p->setRadius(radius);
		return 0;
	}
};

#endif //__LB_ROUNDED_RECTANGLE_H