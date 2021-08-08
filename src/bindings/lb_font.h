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
};

#endif // __LB_FONT_H