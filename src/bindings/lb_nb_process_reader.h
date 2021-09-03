#ifndef __LB_NB_PROCESS_READER_H
#define __LB_NB_PROCESS_READER_H

#include "LuaBinding.h"
#include "non_blocking_process_read.h"

struct ProcessReaderBinding : ManualBind::Binding<ProcessReaderBinding, NonBlockingProcessRead>
{
	static constexpr const char* class_name = "ProcessReader";

	static luaL_Reg* members()
	{
		static luaL_Reg members[] = {
			{ "open", open },
			{ "close", close },
			{ "add", add },
			{ "set", set },
			{ "clear", clear },
			{ "read", read },
			{ nullptr, nullptr }
		};
		return members;
	}

	static int create(lua_State *L)
	{
		NonBlockingProcessReadPtr nbpr = std::make_shared<NonBlockingProcessRead>();
		push( L, nbpr );
		return 1;
	}

	static int open(lua_State* L)
	{
		NonBlockingProcessReadPtr nbpr = fromStack(L,1);
		lua_pushboolean(L, nbpr->open());
		return 1;
	}

	static int close(lua_State* L)
	{
		NonBlockingProcessReadPtr nbpr = fromStack(L,1);
		nbpr->close();
		return 0;
	}

	static int add(lua_State* L)
	{
		NonBlockingProcessReadPtr nbpr = fromStack(L,1);
		std::string arg( luaL_checkstring(L, 2));
		nbpr->addArgument(arg);
		return 0;
	}

	static int set(lua_State* L)
	{
		NonBlockingProcessReadPtr nbpr = fromStack(L,1);
		std::string program( luaL_checkstring(L, 2));
		nbpr->setProgram(program);
		return 0;
	}

	static int clear(lua_State* L)
	{
		NonBlockingProcessReadPtr nbpr = fromStack(L,1);
		nbpr->clearArgs();
		return 0;
	}

	static int read(lua_State* L)
	{
		NonBlockingProcessReadPtr nbpr = fromStack(L,1);
		std::string buffer;
		lua_pushboolean(L, nbpr->read(buffer));
		lua_pushstring(L, buffer.c_str());
		return 2;
	}
};

#endif // __LB_NB_PROCESS_READER_H