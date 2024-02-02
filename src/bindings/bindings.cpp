#include "LuaBinding.h"
#include "lb_application.h"
#include "lb_atlas.h"
#include "lb_color.h"
#include "lb_font.h"
#include "lb_rectangle.h"
#include "lb_rounded_rectangle.h"
#include "lb_renderer.h"
#include "lb_renderlist.h"
#include "lb_texture.h"
#include "lb_nb_subprocess.h"
#include "lb_edit_string.h"
#include "lb_line_list.h"
#include "sdl.h"

using ManualBind::LuaRef;

const char* ColorBinding::prop_keys[] = {"r", "g", "b", "a"};
FontCache FontBinding::cache;

void registerAllBindings(lua_State* L)
{
	ApplicationBinding::register_class(L);
	AtlasBinding::register_class(L);
	ColorBinding::register_class(L);
	FontBinding::register_class(L);
	RectangleBinding::register_class(L);
	RoundedRectangleBinding::register_class(L);
	RenderableBinding::register_class(L);
	RenderListBinding::register_class(L);
	RendererBinding::register_class(L);
	TextureBinding::register_class(L);
	SubProcessBinding::register_class(L);
	EditStringBinding::register_class(L);
	LineListBinding::register_class(L);
}

static SDL_Rect getRectFromTable(lua_State* L, int index)
{
	int t;
	using ManualBind::LuaRef;
	SDL_Rect rect;
	t = lua_gettop(L);
	LuaRef rectTable = LuaRef::fromStack(L, index);

	t = lua_gettop(L);
	if (!rectTable.isTable())
	{
		luaL_error(L, "Parameter %d must be a table.", index);
	}

	t = lua_gettop(L);
	/** Lua tables start at 1 :-) **/
	for (int i = 1; i < 5; i++)
	{
		if (!rectTable[i].isNumber())
		{
			luaL_error(L, "Parameter %d table must have four numbers (x,y,w,h).", index);
		}
	t = lua_gettop(L);
	}

	int x = rectTable[1];
	int y = rectTable[2];
	int w = rectTable[3];
	int h = rectTable[4];

	rect = {x, y, w, h};

	return rect;
}

static const SDL_Renderer* getRenderer(lua_State* L)
{
	lua_getglobal(L, "app");
	lua_getfield(L, -1, "renderer");
	const SDL_Renderer* renderer = RendererBinding::fromStack(L, -1);
	lua_pop(L, 2);

	return renderer;
}