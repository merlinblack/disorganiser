#ifndef SCRIPT_MANAGER_H
#define SCRIPT_MANAGER_H

#include <lua.hpp>
#include "LuaRef.h"
#include <vector>
#include <string>
#include <memory>

class Task
{
	ManualBind::LuaRef ref;
	std::string name;
	bool wake;

	public:
	Task(ManualBind::LuaRef& ref, const std::string& name) : ref(ref), name(name), wake(false) {}
	/** \brief if the task is waiting, signal to stop waiting */
	void wakeUp(bool flag = true) { wake = flag; }

	const ManualBind::LuaRef& getRef() { return ref; }
	const std::string& getName() { return name; }
	int shouldWake() { return wake; }
};

using TaskList = std::vector<Task>;

/**
 * \brief Managages loading and running scripts as well as tasks.
 */
class ScriptManager
{
	lua_State* main;
	TaskList tasks;
	/** current task. Normally increments each call to resume. */
	TaskList::iterator taskIter;

	void threadFromStack(lua_State* L, const std::string& name);

	public:
	ScriptManager();
	~ScriptManager();
	void shutdown();
	bool loadFromFile(const std::string& path);
	bool loadFromString(const std::string& code);

	/** \brief Runs the next coroutine in the list until it yields or exits. */
	bool resume();

	void reportStack(lua_State *thread, bool errorFlag);

	lua_State* getMainLuaState() { return main; }
	ManualBind::LuaRef getGlobal(const std::string &name);

	/** Methods for calling from Lua */
	static int taskFromFunction(lua_State* L);
	static int getTaskList(lua_State* L);
	static int wakeupTask(lua_State* L);
};

using ScriptManagerPtr = std::shared_ptr<ScriptManager>;

#endif //SCRIPT_MANAGER_H