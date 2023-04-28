#ifndef __LB_FONT_H
#define __LB_FONT_H

#include "LuaBinding.h"
#include "font.h"

#include <unordered_map>
#include <sstream>

using WeakFontPtr = std::weak_ptr<Font>;
using FontCache = std::unordered_map<std::string, WeakFontPtr>;

struct FontBinding : public ManualBind::Binding<FontBinding,Font>
{
	static constexpr const char* class_name = "Font";

	static FontCache cache;

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
			{ "sizeText", sizeText },
			{ nullptr, nullptr }
		};
		return members;
	}

	static int create(lua_State* L)
	{
		std::string path = lua_tostring(L, 1);
		int size = lua_tointeger(L,2);

		std::ostringstream oss;
		oss << path << size;
		std::string cacheKey(oss.str());

		if(cache.count(cacheKey))
		{
			FontPtr font = cache[cacheKey].lock();
			if(font) {
				push(L, font);
				return 1;
			}
			/* else our cached font ref count went to zero,
			   so we need to make a new one */
		}

		FontPtr font = std::make_shared<Font>(path, size);

		cache[cacheKey] = font;

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
		FontPtr font = fromStack(L, 1);
		auto [w, h] = font->sizeText(luaL_checkstring(L,2));
		lua_pushinteger(L, w);
		lua_pushinteger(L, h);
		return 2;
	}
};

#endif // __LB_FONT_H