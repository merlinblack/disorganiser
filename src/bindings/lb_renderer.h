#ifndef __LB_RENDERER_H
#define __LB_RENDERER_H

#include "LuaBinding.h"
#include <SDL2/SDL.h>
#include <string>
#include "texture.h"
#include "lb_texture.h"
#include "font.h"
#include "lb_font.h"
#include "lb_color.h"

struct RendererBinding: public ManualBind::PODBinding<RendererBinding,const SDL_Renderer*>
{
	static constexpr const char* class_name = "Renderer";

    static luaL_Reg* members()
    {
        static luaL_Reg members[] = {
            { "textureFromFile", textureFromFile },
            { "textureFromText", textureFromText },
            { nullptr, nullptr }
        };
        return members;
    }

	static int textureFromFile(lua_State* L)
	{
		const SDL_Renderer* renderer = fromStack(L,1);
		std::string path = lua_tostring(L, 2);

		TexturePtr texture = Texture::createFromFile(renderer, path);

		TextureBinding::push(L, texture);

		return 1;
	}

	static int textureFromText(lua_State* L)
	{
		const SDL_Renderer* renderer = fromStack(L,1);
		FontPtr font = FontBinding::fromStack(L,2);
		std::string text = luaL_checkstring(L, 3);
		SDL_Color& color = ColorBinding::fromStack(L,4);

		TexturePtr texture = font->renderTextNice(renderer, text, color);

		TextureBinding::push(L, texture);

		return 1;
	}
};

#endif //__LB_RENDERER_H