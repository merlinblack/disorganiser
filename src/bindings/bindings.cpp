#include "LuaBinding.h"
#include "lb_application.h"
#include "lb_color.h"
#include "lb_renderer.h"
#include "lb_renderlist.h"
#include "lb_texture.h"

const char* ColorBinding::prop_keys[] = {"r", "g", "b", "a"};

void registerAllBindings(lua_State* L)
{
	ApplicationBinding::register_class(L);
	RenderableBinding::register_class(L);
	RenderListBinding::register_class(L);
	RendererBinding::register_class(L);
	ColorBinding::register_class(L);
	TextureBinding::register_class(L);
}