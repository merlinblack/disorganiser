#ifndef __ATLAS_BINDING_H
#define __ATLAS_BINDING_H

#include "LuaBinding.h"
#include "bindings.h"
#include "atlas.h"
#include "lb_texture.h"

struct AtlasBinding : public ManualBind::Binding<AtlasBinding, Atlas>
{
	static constexpr const char* class_name = "Atlas";

	static luaL_Reg* members()
	{
		static luaL_Reg members[] = {
			{ "setTexture", setTexture },
			{ "setScale", setScale },
			{ "addImage", addImage },
			{ "render", render },
			{ nullptr, nullptr }
		};
		return members;
	}

	static int render(lua_State* L)
	{
		const SDL_Renderer* renderer = getRenderer(L);

		AtlasPtr atlas = fromStack(L, 1);

		int index = luaL_checkinteger(L, 2);
		int x = luaL_checkinteger(L, 3);
		int y = luaL_checkinteger(L, 4);

		if (index == 0)
			luaL_error(L, "invalid index (zero)." );

		index--;

		if (index >= (int)atlas->size())
			luaL_error(L, "index to large for this atlas." );

		if (index < 0)
			luaL_error(L, "negitive indices unsupported." );

		atlas->renderImage(renderer, index, x, y);

		return 0;
	}

	static ManualBind::bind_properties* properties()
	{
		static ManualBind::bind_properties properties[] = {
			{ "size", getSize, nullptr },
			{ nullptr, nullptr, nullptr }
		};
		return properties;
	} 

	static int create(lua_State* L)
	{
		AtlasPtr atlas = std::make_shared<Atlas>();

		push(L, atlas);

		return 1;
	}

	static int setTexture(lua_State* L)
	{
		AtlasPtr atlas = fromStack(L, 1);
		TexturePtr texture = TextureBinding::fromStack(L,2);

		atlas->setTexture(texture);

		return 0;
	}

	static int setScale(lua_State* L)
	{
		AtlasPtr atlas = fromStack(L, 1);
		float hScale = luaL_checknumber(L, 2);
		float vScale = luaL_checknumber(L, 2);

		atlas->setScale(hScale, vScale);

		return 0;
	}

	static int addImage(lua_State* L)
	{
		AtlasPtr atlas = fromStack(L, 1);
		
		SDL_Rect src = getRectFromTable(L, 2);

		atlas->addImage(src);

		return 0;
	}

	static int getSize(lua_State* L)
	{
		AtlasPtr atlas = fromStack(L, 1);

		lua_pushinteger(L, atlas->size());

		return 1;
	}
};

#endif // __ATLAS_BINDING_H