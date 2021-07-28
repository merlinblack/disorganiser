#include "LuaBinding.h"
#include "lb_application.h"
#include "lb_renderlist.h"

void registerAllBindings(lua_State* L)
{
	ApplicationBinding::register_class(L);
	RenderableBinding::register_class(L);
	RenderListBinding::register_class(L);
}