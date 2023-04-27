#ifndef __BINDINGS_H
#define __BINDINGS_H

#include <lua.hpp>
#include "sdl.h"

void registerAllBindings(lua_State* L);
static SDL_Rect getRectFromTable(lua_State* L, int index);

#endif //__BINDINGS_H