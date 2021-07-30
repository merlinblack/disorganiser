#ifndef __LB_TEXTURE_H
#define __LB_TEXTURE_H

#include "LuaBinding.h"
#include "texture.h"

struct TextureBinding : public ManualBind::Binding<TextureBinding,Texture>
{
	static constexpr const char* class_name = "Texture";

	static ManualBind::bind_properties* properties()
	{
		static ManualBind::bind_properties properties[] = {
			{ "width", getWidth, nullptr },
			{ "height", getHeight, nullptr },
			{ nullptr, nullptr, nullptr }
		};
		return properties;
	}

	static int getWidth(lua_State* L)
	{
		TexturePtr t = fromStack(L,1);
		lua_pushinteger(L, t->getWidth());
		return 1;
	}

	static int getHeight(lua_State* L)
	{
		TexturePtr t = fromStack(L,1);
		lua_pushinteger(L, t->getHeight());
		return 1;
	}
};

#endif // __LB_TEXTURE_H