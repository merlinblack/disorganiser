#ifndef __EDIT_STRING_BINDING_H
#define __EDIT_STRING_BINDING_H

#include "LuaBinding.h"
#include "edit_string.h"

struct EditStringBinding : public ManualBind::Binding<EditStringBinding, EditString>
{
	static constexpr const char* class_name = "EditString";

	static luaL_Reg* members()
	{
		static luaL_Reg members[] = {
			{ "__tostring", toString },
			{ "getString", toString },
			{ "setString", setString },
			{ "gotoStart", gotoStart },
			{ "gotoEnd", gotoEnd },
			{ "back", back },
			{ "forward", forward },
			{ "backWord", backWord },
			{ "forwardWord", forwardWord },
			{ "index", getIndex },
			{ "clear", clear },
			{ "insert", insert },
			{ "erase", erase },
			{ nullptr, nullptr }
		};
		return members;
	}

	static int create(lua_State* L)
	{
		EditStringPtr es = std::make_shared<EditString>();
		push(L, es);
		return 1;
	}

	static int toString(lua_State* L)
	{
		EditStringPtr es = fromStack(L, 1);
		lua_pushstring(L, es->toString().c_str());
		return 1;
	}

	static int setString(lua_State* L)
	{
		EditStringPtr es = fromStack(L, 1);
		es->setString(luaL_checkstring(L,2));
		return 0;
	}

	static int gotoStart(lua_State* L)
	{
		EditStringPtr es = fromStack(L, 1);
		es->gotoStart();
		return 0;
	}

	static int gotoEnd(lua_State* L)
	{
		EditStringPtr es = fromStack(L, 1);
		es->gotoEnd();
		return 0;
	}

	static int back(lua_State* L)
	{
		EditStringPtr es = fromStack(L, 1);
		es->back();
		return 0;
	}

	static int forward(lua_State* L)
	{
		EditStringPtr es = fromStack(L, 1);
		es->forward();
		return 0;
	}

	static int backWord(lua_State* L)
	{
		EditStringPtr es = fromStack(L, 1);
		es->backWord();
		return 0;		
	}

	static int forwardWord(lua_State* L)
	{
		EditStringPtr es = fromStack(L, 1);
		es->forwardWord();
		return 0;
	}

	static int getIndex(lua_State* L)
	{
		EditStringPtr es = fromStack(L, 1);
		lua_pushinteger(L, es->getCharacaterIndex());
		return 1;
	}

	static int clear(lua_State* L)
	{
		EditStringPtr es = fromStack(L, 1);
		es->clear();
		return 0;		
	}

	static int insert(lua_State* L)
	{
		EditStringPtr es = fromStack(L, 1);
		es->insert(luaL_checkstring(L, 2));
		return 0;		
	}

	static int erase(lua_State* L)
	{
		EditStringPtr es = fromStack(L, 1);
		es->erase();
		return 0;
	}
};

#endif // __EDIT_STRING_BINDING_H