#ifndef __LB_RENDERER_H
#define __LB_RENDERER_H

#include "LuaBinding.h"
#include <SDL2/SDL.h>
#include <string>
#include "texture.h"
#include "lb_texture.h"

struct RendererBinding: public ManualBind::PODBinding<RendererBinding,const SDL_Renderer*>
{
	static constexpr const char* class_name = "Renderer";

    static luaL_Reg* members()
    {
        static luaL_Reg members[] = {
            { "textureFromFile", textureFromFile },
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
};

#endif //__LB_RENDERER_H