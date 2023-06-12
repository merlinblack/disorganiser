#ifndef __LB_TEXTURE_H
#define __LB_TEXTURE_H

#include "LuaBinding.h"
#include "texture.h"
#include "font.h"
#include "lb_font.h"
#include "lb_color.h"
#include "bindings.h"

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

	static int create(lua_State* L)
	{
		if(luaL_testudata(L, 1, "Font"))
			return createFromText(L);
		else
			return createFromFile(L);
	}

	static int createFromFile(lua_State *L)
	{
		std::string path = lua_tostring(L, 1);
		const SDL_Renderer* renderer = getRenderer(L);

		TexturePtr texture = Texture::createFromFile(renderer, path);

		TextureBinding::push(L, texture);

		return 1;
	}

	static int createFromText(lua_State *L)
	{
		FontPtr font = FontBinding::fromStack(L,1);
		std::string text = luaL_checkstring(L, 2);
		SDL_Color& color = ColorBinding::fromStack(L,3);
		const SDL_Renderer* renderer = getRenderer(L);

		TexturePtr texture = font->renderTextNice(renderer, text, color);

		TextureBinding::push(L, texture);

		return 1;
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