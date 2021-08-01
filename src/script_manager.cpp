#include "script_manager.h"
#include "bindings.h"
#include <lua.hpp>
#include <SDL2/SDL.h>
#include <sstream>

const std::string dumpstack_str(lua_State* L );

static const char LuaRegisteryGUID = 0;

ScriptManager::ScriptManager()
{
	main = luaL_newstate();
	luaL_openlibs(main);
	registerAllBindings(main);
	lua_pushlightuserdata(main,(void*)&LuaRegisteryGUID);
	lua_pushlightuserdata(main,this);
	lua_settable(main, LUA_REGISTRYINDEX);

	lua_pushcfunction(main, taskFromFunction);
	lua_setglobal(main,"addTask");
}

ScriptManager::~ScriptManager()
{
	shutdown();
}

void ScriptManager::shutdown()
{
	if (main)
	{
		lua_close(main);
		main = nullptr;
	}
}

ManualBind::LuaRef ScriptManager::getGlobal(const std::string& name)
{
	return ManualBind::LuaRef::getGlobal(main, name.c_str());
}

/** \note static member **/
int ScriptManager::taskFromFunction(lua_State* L)
{
	lua_pushlightuserdata(L, (void*)&LuaRegisteryGUID);
	lua_gettable(L, LUA_REGISTRYINDEX);
	ScriptManager* self = static_cast<ScriptManager *>(lua_touserdata(L, -1));
	lua_pop(L,1);

	if (lua_type(L,1) != LUA_TFUNCTION)
	{
		luaL_error(L, "Parameter must be a function");
	}

	self->threadFromStack(L);

	return 0;
}

bool ScriptManager::loadFromString(const std::string& code)
{
	if (luaL_loadstring(main, code.c_str()))
	{
		std::string error(lua_tostring(main, -1));

		SDL_Log(error.c_str());
		return true;
	}

	return threadFromStack(main);
}

bool ScriptManager::loadFromFile(const std::string& path)
{
	if (luaL_loadfile(main, path.c_str()))
	{
		std::string error(lua_tostring(main, -1));

		SDL_Log(error.c_str());
		return true;
	}

	return threadFromStack(main);
}

bool ScriptManager::threadFromStack(lua_State* L)
{
	lua_State* thread = lua_newthread(L);

	int coroutine = luaL_ref(L, LUA_REGISTRYINDEX);

	lua_xmove(L, thread, 1);

	coroutines.push_back(coroutine);
	coroutineIter = coroutines.begin();

	return false;
}

bool ScriptManager::resume()
{
	if (coroutines.empty() == true)
	{
		return true;
	}

	lua_rawgeti(main, LUA_REGISTRYINDEX, *coroutineIter);

	lua_State* thread = lua_tothread(main, -1);
	lua_pop(main, 1);

	int nResults;
	int ret = lua_resume(thread, main, 0, &nResults);
	bool errorFlag = false;

	switch (ret)
	{
		default:
			errorFlag = true;
			// Fall through.
		case 0:
			// Ran to completion or had an error.
			luaL_unref(main, LUA_REGISTRYINDEX, *coroutineIter);
			coroutineIter = coroutines.erase(coroutineIter);
			break;
		case LUA_YIELD:
			coroutineIter++;
			break;
	}

	if (coroutineIter == coroutines.end())
	{
		coroutineIter = coroutines.begin();
	}

	reportStack(thread, errorFlag);

	lua_pop(thread, nResults);

	return errorFlag;
}

void ScriptManager::reportStack( lua_State* thread, bool wasError )
{
    // Report stack contents
    // In the case of a yielded chunk these are the parameters to yield.
    if( wasError ) {
      lua_getglobal( thread, "print" );
      lua_pushliteral( thread, "Error" );
      lua_pushvalue( thread, -3 );
      lua_pcall(thread, 2, 0, 0);
      lua_settop( thread, 0 );
    }
    else if ( lua_gettop(thread) > 0)
    {
      std::string stack = dumpstack_str( thread );
      lua_settop( thread, 0 );
      lua_getglobal( thread, "print" );
      lua_pushstring( thread, stack.c_str() );
      lua_pcall(thread, 1, 0, 0);
    }
}

const std::string dumpstack_str(lua_State* L )
{
    static std::stringstream ss;
    int i;
    int top = lua_gettop(L);

    ss.str("\n");

    for (i = 1; i <= top; i++)
    {
        ss << i << "> " << luaL_typename(L,i) << " - ";
        switch (lua_type(L, i))
        {
            case LUA_TNUMBER:
                ss << lua_tonumber(L,i) << "\n";
            break;
            case LUA_TUSERDATA:
            case LUA_TSTRING:
                ss << luaL_tolstring(L, i, nullptr) << "\n";
                lua_pop(L,1);
                break;
            case LUA_TBOOLEAN:
                ss << (lua_toboolean(L, i) ? "true" : "false") << "\n";
                break;
            case LUA_TNIL:
                ss << "nil\n";
                break;
            default:
                ss << std::hex << "0x" << lua_topointer(L,i) << "\n";
                break;
        }
    }
    return ss.str();
}