#include "script_manager.h"
#include "bindings.h"
#include <lua.hpp>
#include <SDL2/SDL.h>
#include <sstream>
#include <algorithm>

using ManualBind::LuaRef;

const std::string dumpstack_str(lua_State* L );

static const char LuaRegisteryGUID = 0;

ScriptManager::ScriptManager()
{
	tasks.reserve(10);
	main = luaL_newstate();
	luaL_openlibs(main);
	registerAllBindings(main);
	lua_pushlightuserdata(main,(void*)&LuaRegisteryGUID);
	lua_pushlightuserdata(main,this);
	lua_settable(main, LUA_REGISTRYINDEX);

	lua_pushcfunction(main, taskFromFunction);
	lua_setglobal(main,"addTask");
	lua_pushcfunction(main, getTaskList);
	lua_setglobal(main,"getTasks");
	lua_pushcfunction(main, wakeupTask);
	lua_setglobal(main,"wakeTask");

	luaL_dostring( main, "package.path = './scripts/?.lua;' .. package.path" );
	luaL_dostring( main, "package.cpath = './scripts/?.so;' .. package.cpath" );
	luaL_dostring( main, "package.path = '/usr/share/lua/5.4/?.lua;' .. package.path" );
	luaL_dostring( main, "package.cpath = '/usr/lib64/lua/5.4/?.so;' .. package.cpath" );
}

ScriptManager::~ScriptManager()
{
	shutdown();
}

void ScriptManager::shutdown()
{
	if (main)
	{
		tasks.clear();
		lua_close(main);
		main = nullptr;
	}
}

LuaRef ScriptManager::getGlobal(const std::string& name)
{
	return LuaRef::getGlobal(main, name.c_str());
}

ScriptManager* getInstance(lua_State* L)
{
	lua_pushlightuserdata(L, (void*)&LuaRegisteryGUID);
	lua_gettable(L, LUA_REGISTRYINDEX);
	ScriptManager* self = static_cast<ScriptManager *>(lua_touserdata(L, -1));
	lua_pop(L,1);

	return self;
}

/** \note static member **/
int ScriptManager::taskFromFunction(lua_State* L)
{
	ScriptManager* self = getInstance(L);

	if (lua_type(L,1) != LUA_TFUNCTION)
	{
		luaL_error(L, "Parameter must be a function");
	}

	std::string name = luaL_optstring(L, 2, "<unknown>");

	self->threadFromStack(L, name);

	return 0;
}

/** \note static member **/
int ScriptManager::getTaskList(lua_State* L)
{
	ScriptManager* self = getInstance(L);

	LuaRef table = LuaRef::newTable(L);

	for(auto& task : self->tasks)
	{
		table.append(task.getName());
	}

	table.push();

	return 1;
}

/** \note static member **/
int ScriptManager::wakeupTask(lua_State* L)
{
	ScriptManager* self = getInstance(L);

	std::string name = luaL_checkstring(L, 1);

	auto matchName = [&name](Task& t){ return t.getName() == name; };

	auto i = std::find_if(self->tasks.begin(), self->tasks.end(), matchName);

	if (i != self->tasks.end())
	{
		i->wakeUp();
	}

	return 0;
}

bool ScriptManager::loadFromString(const std::string& code)
{
	if (luaL_loadstring(main, code.c_str()))
	{
		std::string error(lua_tostring(main, -1));

		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "%s", error.c_str());
		return true;
	}

	threadFromStack(main, code);

	return false;
}

bool ScriptManager::loadFromFile(const std::string& path)
{
	if (luaL_loadfile(main, path.c_str()))
	{
		std::string error(lua_tostring(main, -1));

		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "%s", error.c_str());
		return true;
	}

	threadFromStack(main, path);

	return false;
}

void ScriptManager::threadFromStack(lua_State* L, const std::string& name)
{
	lua_State* thread = lua_newthread(main);

	LuaRef coroutine = LuaRef::fromStack(main);

	lua_pop(main, 1);

	lua_xmove(L, thread, lua_gettop(L));

	tasks.emplace_back(coroutine, name);
	taskIter = tasks.begin();
}

bool ScriptManager::resume()
{
	if (tasks.empty() == true)
	{
		return true;
	}

	TaskList::iterator currentTask = taskIter;

	currentTask->getRef().push();
	lua_State* thread = lua_tothread(main, -1);
	lua_pop(main, 1);

	if (currentTask->shouldWake())
	{
		lua_pushliteral(thread, "wakeup");
		currentTask->wakeUp(false);
	}

	int nargs = lua_gettop(thread);
	if (lua_type(thread, 1) == LUA_TFUNCTION)
	{
		// Starting task for first time. Function is the task function.
		--nargs;
	}

	int nResults;
	int ret = lua_resume(thread, main, nargs, &nResults);

	bool errorFlag = false;

	switch (ret)
	{
		default:
			errorFlag = true;
			// Fall through.
		case 0:
			// Ran to completion or had an error.
			taskIter = tasks.erase(currentTask);
			break;
		case LUA_YIELD:
			taskIter++;
			break;
	}

	if (taskIter == tasks.end())
	{
		taskIter = tasks.begin();
	}

	reportStack(thread, errorFlag);

	lua_settop(thread, 0);

	return errorFlag;
}

void ScriptManager::reportStack( lua_State* thread, bool wasError )
{
	// Report stack contents
	// In the case of a yielded chunk these are the parameters to yield.
	if( wasError ) {
	  lua_getglobal( thread, "write" );
	  if (!lua_isfunction( thread, -1))
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
	  lua_getglobal( thread, "write" );
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
