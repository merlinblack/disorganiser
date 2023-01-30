#include "LuaBinding.h"
#include "lb_application.h"
#include "lb_color.h"
#include "lb_font.h"
#include "lb_rectangle.h"
#include "lb_renderer.h"
#include "lb_renderlist.h"
#include "lb_texture.h"
#include "lb_nb_process_reader.h"
#include "lb_edit_string.h"
#include "lb_line_list.h"

const char* ColorBinding::prop_keys[] = {"r", "g", "b", "a"};

void registerAllBindings(lua_State* L)
{
	ApplicationBinding::register_class(L);
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