#ifndef __LB_RENDERER_H
#define __LB_RENDERER_H

#include "LuaBinding.h"
#include <SDL2/SDL.h>

struct RendererBinding: public ManualBind::PODBinding<RendererBinding,const SDL_Renderer*>
{
	static constexpr const char* class_name = "Renderer";
};

#endif //__LB_RENDERER_H