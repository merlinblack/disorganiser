#ifndef SCRIPT_MANAGER_H
#define SCRIPT_MANAGER_H

#include <lua.hpp>
#include "LuaRef.h"
#include <vector>
#include <string>
#include <memory>

using CoroutineList = std::vector<int>;

/**
 * \brief Managages loading and running scripts
 */
class ScriptManager
{
	lua_State* main;
	CoroutineList coroutines;
	CoroutineList::iterator coroutineIter;

	bool threadFromStack();

	public:
	ScriptManager();
	~ScriptManager();
	bool loadFromFile(const std::string& path);
	bool loadFromString(const std::string& code);

	/** \brief Runs the next coroutine in the list until it yields or exits. */
	bool resume();

	void reportStack(lua_State *thread, bool errorFlag);

	ManualBind::LuaRef &getGlobal(const std::string &name);
};

using ScriptManagerPtr = std::shared_ptr<ScriptManager>;

#endif //SCRIPT_MANAGER_H