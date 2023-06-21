#ifndef __LB_RENDERLIST_H
#define __LB_RENDERLIST_H

#include "LuaBinding.h"
#include "renderlist.h"

struct RenderableBinding : public ManualBind::Binding<RenderableBinding,Renderable>
{
	static constexpr const char* class_name = "Renderable";

	static int create( lua_State* L )
	{
		return luaL_error( L, "Can not make an instance of an abstract class");
	}

};

struct RenderListBinding : public ManualBind::Binding<RenderListBinding,RenderList>
{
	static constexpr const char* class_name = "RenderList";

	static luaL_Reg* members()
	{
		static luaL_Reg members[] = {
			{ "__upcast", upcast },
			{ "sort", sort },
			{ "insert", insert },
			{ "remove", remove },
			{ "clear", clear },
			{ "add", add },
			{ "shouldRender", shouldRender },
			{ nullptr, nullptr }
		};
		return members;
	}

	static int create( lua_State* L )
	{
		RenderListPtr rl = std::make_shared<RenderList>();

		push( L, rl );

		return 1;
	}

	static int sort( lua_State* L )
	{
		RenderListPtr rl = fromStack( L, 1 );
		rl->sort();
		return 0;
	}

	static int insert( lua_State* L )
	{
		RenderListPtr rl = fromStack( L, 1 );
		ManualBind::LuaBindingUpCast( L, 2 );
		if (!RenderableBinding::isType( L,2 ))
		{
			return luaL_error(L, "Failed to upcast argument #1 to Renderable");
		}
		RenderablePtr r = RenderableBinding::fromStack( L, 2 );

		rl->insert( std::move(r) );

		return 0;
	}

	static int remove( lua_State* L )
	{
		RenderListPtr rl = fromStack( L, 1 );
		ManualBind::LuaBindingUpCast( L, 2 );
		RenderablePtr r = RenderableBinding::fromStack( L, 2 );

		rl->remove( r );

		return 0;
	}

	static int clear( lua_State* L )
	{
		RenderListPtr rl = fromStack( L, 1 );

		rl->clear();

		return 0;
	}

	static int add( lua_State* L )
	{
		RenderListPtr rl = fromStack( L, 1 );
		ManualBind::LuaBindingUpCast( L, 2 );
		if (!RenderableBinding::isType( L,2 ))
		{
			return luaL_error(L, "Failed to upcast argument #1 to Renderable");
		}
		RenderablePtr r = RenderableBinding::fromStack( L, 2 );

		rl->add( std::move(r) );

		return 0;
	}

	static int shouldRender( lua_State* L )
	{
		RenderListPtr rl = fromStack( L, 1 );
		bool flag = luaL_opt(L, lua_toboolean, 2, true);

		rl->setShouldRender(flag);

		return 0;
	}

	static int upcast( lua_State *L )
	{
		RenderListPtr p = fromStack( L, 1 );

		RenderablePtr rp = std::dynamic_pointer_cast<Renderable>( p );

		RenderableBinding::push( L, rp );

		return 1;
	}
};

#endif // __LB_RENDERLIST_H
