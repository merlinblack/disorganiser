#ifndef __LB_RECTANGLE_H
#define __LB_RECTANGLE_H

#include "LuaBinding.h"
#include "LuaRef.h"
#include "bindings.h"
#include "rectangle.h"
#include "lb_renderlist.h"
#include "lb_color.h"
#include "lb_texture.h"
#include <sstream>

struct RectangleBinding : public ManualBind::Binding<RectangleBinding,Rectangle>
{
	static constexpr const char* class_name = "Rectangle";

	static luaL_Reg* members()
	{
		static luaL_Reg members[] = {
			{ "__upcast", upcast },
			{ "__tostring", tostring },
			{ "setDest", setDest },
			{ "setSource", setSource },
			{ "setClip", setClip },
			{ "setColor", setColor },
			{ "setFill", setFill },
			{ nullptr, nullptr }
		};
		return members;
	}

	static ManualBind::bind_properties* properties()
	{
		static ManualBind::bind_properties properties[] = {
			{ "texture", getTexture, setTexture },
			{ nullptr, nullptr, nullptr }
		};
		return properties;
	}

	static int create(lua_State *L)
	{
		using ManualBind::LuaRef;

		if (luaL_testudata(L, 1, ColorBinding::class_name))
		{
			return createColorFillRectangle(L);
		}

		if(!luaL_testudata(L, 1, TextureBinding::class_name))
		{
			return luaL_error(L, "Parameter #1 should be either a Color or Texture.");
		}

		TexturePtr texture = TextureBinding::fromStack(L,1);
		LuaRef a = LuaRef::fromStack(L, 2);
		LuaRef b = LuaRef::fromStack(L, 3);

		if (a.isNumber() && b.isNumber())
		{
			RectanglePtr rectangle = std::make_shared<Rectangle>(texture, (int)a, (int)b);
			push(L, rectangle);
			return 1;
		}

		if (a.isTable() && (b.isTable() || b.isNil()))
		{
			SDL_Rect dest = getRectFromTable(L, 2);
			SDL_Rect src;
			if (b.isNil()) {
				src = {0,0,0,0};
			}
			else
			{
				src = getRectFromTable(L,3);
			}

			RectanglePtr rectangle = std::make_shared<Rectangle>(texture, dest, src);
			push(L, rectangle);
			return 1;
		}

		return luaL_error(L, "Rectangle with texture, must have either two numbers, or one or two tables with four numbers each.");
	}

	static int createColorFillRectangle(lua_State* L)
	{
		using ManualBind::LuaRef;

		SDL_Color &color = ColorBinding::fromStack(L, 1);
		LuaRef fill = LuaRef::fromStack(L, 2);

		if (!fill.isBool())
		{
			return luaL_error(L, "Second parameter for 'fill' must be a boolean.");
		}

		SDL_Rect dest = getRectFromTable(L, 3);

		RectanglePtr rectangle = std::make_shared<Rectangle>(color, fill, dest);

		push(L, rectangle);

		return 1;
	}

	static int upcast( lua_State *L )
	{
		RectanglePtr p = fromStack( L, 1 );

		RenderablePtr rp = std::dynamic_pointer_cast<Renderable>( p );

		RenderableBinding::push( L, rp );

		return 1;
	}

	static int tostring( lua_State* L )
	{
		RectanglePtr r = fromStack( L, 1 );
		std::stringstream ss;

		ss << "Rectangle: " << std::hex << r.get() << std::dec;
		ss << " dest: { ";
		SDL_Rect rect = r->getDest();
		ss << rect.x << ", " << rect.y << ", " << rect.w << ", " << rect.h;
		ss << " }, src: { ";
		rect = r->getSource();
		ss << rect.x << ", " << rect.y << ", " << rect.w << ", " << rect.h;
		ss << "}, tex: " << std::hex << r->getTexture().get();

		lua_pushstring( L, ss.str().c_str() );

		return 1;
	}

	static int setTexture( lua_State* L )
	{
		RectanglePtr p = fromStack( L, 1 );
		TexturePtr t = TextureBinding::fromStack( L, 3);

		p->setTexture(t);
		return 0;
	}

	static int getTexture( lua_State* L )
	{
		RectanglePtr p = fromStack( L, 1 );

		TextureBinding::push( L, p->getTexture() );

		return 1;
	}

	static int setDest( lua_State* L )
	{
		RectanglePtr p = fromStack( L, 1 );
		SDL_Rect r = getRectFromTable( L, 2 );

		p->setDest(r);
		return 0;
	}

	static int setSource( lua_State* L )
	{
		RectanglePtr p = fromStack( L, 1 );
		SDL_Rect r = getRectFromTable( L, 2 );

		p->setSource(r);
		return 0;
	}
	
	static int setClip( lua_State* L )
	{
		RectanglePtr p = fromStack( L, 1 );
		SDL_Rect r = getRectFromTable( L, 2 );

		p->setClip(r);
		return 0;
	}	

	static int setColor( lua_State* L )
	{
		RectanglePtr p = fromStack( L, 1 );
		SDL_Color& c = ColorBinding::fromStack( L, 2 );

		p->setColor(c);
		return 0;
	}

	static int setFill( lua_State* L )
	{
		RectanglePtr p = fromStack( L, 1 );
		bool fill = lua_toboolean( L, 2 );

		p->setFill(fill);
		return 0;
	}
};

#endif //__LB_RECTANGLE_H