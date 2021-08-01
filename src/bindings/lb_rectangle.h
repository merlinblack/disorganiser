#ifndef __LB_RECTANGLE_H
#define __LB_RECTANGLE_H

#include "LuaBinding.h"
#include "LuaRef.h"
#include "rectangle.h"
#include "lb_color.h"
#include "lb_texture.h"

struct RectangleBinding : public ManualBind::Binding<RectangleBinding,Rectangle>
{
	static constexpr const char* class_name = "Rectangle";

	static luaL_Reg* members()
	{
		static luaL_Reg members[] = {
			{ "__upcast", upcast },
			{ "setTexture", setTexture },
			{ nullptr, nullptr }
		};
		return members;
	}

	static ManualBind::bind_properties* properties()
	{
		static ManualBind::bind_properties properties[] = {
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
			return luaL_error(L, "Parameter #1 should be either a Color or Texure.");
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

	static SDL_Rect getRectFromTable(lua_State* L, int index)
	{
		using ManualBind::LuaRef;
		SDL_Rect rect;
		LuaRef rectTable = LuaRef::fromStack(L, index);

		if (!rectTable.isTable())
		{
			luaL_error(L, "Parameter %d must be a table.", index);
		}

		/** Lua tables start at 1 :-) **/
		for (int i = 1; i < 5; i++)
		{
			if (!rectTable[i].isNumber())
			{
				luaL_error(L, "Parameter %d table must have four numbers (x,y,w,h).", index);
			}
		}

		LuaRef x = rectTable[1];
		LuaRef y = rectTable[2];
		LuaRef w = rectTable[3];
		LuaRef h = rectTable[4];

		rect = {x, y, w, h};

		return rect;
	}

	static int upcast( lua_State *L )
	{
		RectanglePtr p = fromStack( L, 1 );

		RenderablePtr rp = std::dynamic_pointer_cast<Renderable>( p );

		RenderableBinding::push( L, rp );

		return 1;
	}

	static int setTexture( lua_State* L )
	{
		RectanglePtr p = fromStack( L, 1 );
		TexturePtr t = TextureBinding::fromStack( L, 2);

		p->setTexture(t);
		return 0;
	}
};

#endif //__LB_RECTANGLE_H