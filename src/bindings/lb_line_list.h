#ifndef __LB_LINE_LIST_H
#define __LB_LINE_LIST_H

#include <sstream>
#include "LuaBinding.h"
#include "LuaRef.h"
#include "line_list.h"
#include "lb_color.h"
#include "lb_renderlist.h"

struct LineListBinding : public ManualBind::Binding<LineListBinding,LineList>
{
	static constexpr const char* class_name = "LineList";

	static luaL_Reg* members()
	{
		static luaL_Reg members[] = {
			{ "__upcast", upcast },
			{ "__tostring", tostring },
			{ "addPoint", addPoint },
			{ nullptr, nullptr }
		};
		return members;
	}

	static ManualBind::bind_properties* properties()
	{
		static ManualBind::bind_properties properties[] = {
			{ "color", nullptr, setColor },
			{ nullptr, nullptr, nullptr }
		};
		return properties;
	}

	static int create(lua_State *L)
	{
		LineListPtr ll = std::make_shared<LineList>();

		if (luaL_testudata(L, 1, ColorBinding::class_name))
		{
			SDL_Color &color = ColorBinding::fromStack(L, 1);
			ll->setColor(color);
		}

		push(L, ll);

		return 1;
	}

	static int upcast( lua_State *L )
	{
		LineListPtr p = fromStack( L, 1 );

		RenderablePtr rp = std::dynamic_pointer_cast<Renderable>( p );

		RenderableBinding::push( L, rp );

		return 1;
	}

	static int tostring( lua_State* L )
	{
		LineListPtr ll = fromStack( L, 1 );
		std::stringstream ss;

		ss << "LineList: " << std::hex << ll.get() << std::dec;
		ss << " points: ";

		for (const auto& pt : ll->getPoints() )
			ss << "(" << pt.x << ", " << pt.y << ") ";

		lua_pushstring( L, ss.str().c_str() );

		return 1;
	}

	static int addPoint( lua_State* L )
	{
		LineListPtr ll = fromStack( L, 1 );
		int x = luaL_checkinteger( L, 2 );
		int y = luaL_checkinteger( L, 3 );

		ll->addPoint({x,y});

		return 0;
	}

	static int setColor( lua_State* L )
	{
		LineListPtr ll = fromStack( L, 1 );
		SDL_Color& color = ColorBinding::fromStack( L, 3 );

		ll->setColor(color);
		return 0;
	}
};

#endif //__LB_LINE_LIST_H