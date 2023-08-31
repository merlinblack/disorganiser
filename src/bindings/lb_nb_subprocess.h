#ifndef __LB_NB_SUBPROCESS__H
#define __LB_NB_SUBPROCESS__H

#include "LuaBinding.h"
#include "non_blocking_process.h"

struct SubProcessBinding : ManualBind::Binding<SubProcessBinding, NonBlockingProcess>
{
	static constexpr const char* class_name = "SubProcess";

	static luaL_Reg* members()
	{
		static luaL_Reg members[] = {
			{ "open", open },
			{ "close", close },
			{ "add", add },
			{ "set", set },
			{ "clear", clear },
			{ "read", read },
			{ "write", write },
			{ "closeWrite", closeWrite },
			{ nullptr, nullptr }
		};
		return members;
	}

	static int create(lua_State *L)
	{
		NonBlockingProcessPtr nbpr = std::make_shared<NonBlockingProcess>();
		push( L, nbpr );
		return 1;
	}

	static int open(lua_State* L)
	{
		NonBlockingProcessPtr nbpr = fromStack(L,1);
		bool openWriteChannel = luaL_opt(L, lua_toboolean, 2, false);
		lua_pushboolean(L, nbpr->open(openWriteChannel));
		return 1;
	}

	static int close(lua_State* L)
	{
		NonBlockingProcessPtr nbpr = fromStack(L,1);
		nbpr->close();
		return 0;
	}

	static int add(lua_State* L)
	{
		NonBlockingProcessPtr nbpr = fromStack(L,1);
		std::string arg( luaL_checkstring(L, 2));
		nbpr->addArgument(arg);
		return 0;
	}

	static int set(lua_State* L)
	{
		NonBlockingProcessPtr nbpr = fromStack(L,1);
		std::string program( luaL_checkstring(L, 2));
		nbpr->setProgram(program);
		return 0;
	}

	static int clear(lua_State* L)
	{
		NonBlockingProcessPtr nbpr = fromStack(L,1);
		nbpr->clearArgs();
		return 0;
	}

	static int read(lua_State* L)
	{
		NonBlockingProcessPtr nbptr = fromStack(L,1);
		std::string buffer;
		lua_pushboolean(L, nbptr->read(buffer));
		lua_pushstring(L, buffer.c_str());
		return 2;
	}

	static int write(lua_State* L)
	{
		NonBlockingProcessPtr nbptr = fromStack(L,1);
		std::string buffer = lua_tostring(L, 2);

		lua_pushboolean(L, nbptr->write(buffer));
		return 1;
	}

	static int closeWrite(lua_State* L)
	{
		NonBlockingProcessPtr nbpr = fromStack(L,1);
		nbpr->closeWriteChannel();
		return 0;
	}
};

#endif // __LB_NB_SUBPROCESS_H