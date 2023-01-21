#ifndef __LB_FONT_H
#define __LB_FONT_H

#include "LuaBinding.h"
#include "font.h"

struct FontBinding : public ManualBind::Binding<FontBinding,Font>
{
	static constexpr const char* class_name = "Font";

	static ManualBind::bind_properties* properties()
	{
		static ManualBind::bind_properties properties[] = {
			{ "lineHeight", getLineHeight, nullptr },
			{ nullptr, nullptr, nullptr}
		};

		return properties;
	}

	static luaL_Reg* members()
	{
		static luaL_Reg members[] = {
			{ "sizeText", sizeText }
		};
		return members;
	}

	static int create(lua_State* L)
	{
		std::string path = lua_tostring(L, 1);
		int size = lua_tointeger(L,2);

		FontPtr font = std::make_shared<Font>(path, size);

		push(L, font);

		return 1;
	}

	static int getLineHeight( lua_State* L )
	{
		FontPtr font = fromStack( L, 1);
		lua_pushinteger( L, font->lineHeight() );
		return 1;
	}

	static int sizeText(lua_State* L)
	{
		int w, h;
		FontPtr font = fromStack(L, 1);
		font->sizeText(luaL_checkstring(L,2), &w, &h);
		lua_pushinteger(L, w);
		lua_pushinteger(L, h);
		return 2;
	}
};

#endif // __LB_FONT_H