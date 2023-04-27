#include "LuaBinding.h"
#include "lb_application.h"
//#include "lb_atlas.h"
#include "lb_color.h"
#include "lb_font.h"
#include "lb_rectangle.h"
#include "lb_renderer.h"
#include "lb_renderlist.h"
#include "lb_texture.h"
#include "lb_nb_process_reader.h"
#include "lb_edit_string.h"
#include "lb_line_list.h"
#include "sdl.h"

using ManualBind::LuaRef;

const char* ColorBinding::prop_keys[] = {"r", "g", "b", "a"};

void registerAllBindings(lua_State* L)
{
	ApplicationBinding::register_class(L);
//	AtlasBinding::register_class(L);
	ColorBinding::register_class(L);
	FontBinding::register_class(L);
	RectangleBinding::register_class(L);
	RenderableBinding::register_class(L);
	RenderListBinding::register_class(L);
	RendererBinding::register_class(L);
	TextureBinding::register_class(L);
	ProcessReaderBinding::register_class(L);
	EditStringBinding::register_class(L);
	LineListBinding::register_class(L);
}

static SDL_Rect getRectFromTable(lua_State* L, int index)
{
	using ManualBind::LuaRef;
	SDL_Rect rect;
	LuaRef rectTable = LuaRef::fromStack(L, index);

	if (!rectTable.isTable())
	{
		luaL_error(L, "Parameter %d must be a table.", index);
	}

	/** Lua tables start at 1 :-) **/
	for (int i = 1; i < 5; i++)
	{
		if (!rectTable[i].isNumber())
		{
			luaL_error(L, "Parameter %d table must have four numbers (x,y,w,h).", index);
		}
	}

	LuaRef x = rectTable[1];
	LuaRef y = rectTable[2];
	LuaRef w = rectTable[3];
	LuaRef h = rectTable[4];

	rect = {x, y, w, h};

	return rect;
}