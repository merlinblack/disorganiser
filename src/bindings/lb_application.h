#ifndef __LB_APPLICATION_H
#define __LB_APPLICATION_H

#include "LuaBinding.h"
#include "application.h"
#include "lb_renderlist.h"
#include "lb_renderer.h"

struct ApplicationBinding : public ManualBind::Binding<ApplicationBinding,Application>
{
	static constexpr const char* class_name = "Application";

	static ManualBind::bind_properties* properties()
	{
		static ManualBind::bind_properties properties[] = {
			{ "shouldStop", get, setStopFlag },
			{ "shouldRender", get, setRenderFlag },
			{ "ticks", get, nullptr },
			{ "renderer", get, nullptr },
			{ "renderList", getRenderList, setRenderList },
			{ nullptr, nullptr, nullptr }
		};
		return properties;
	}

	static int get(lua_State* L)
	{
		ApplicationPtr app = fromStack(L, 1);
		std::string field(lua_tostring(L, 2));

		if (field == "shouldStop")
		{
			lua_pushboolean(L, app->getShouldStop());
			return 1;
		}

		if (field == "shouldRender")
		{
			lua_pushboolean(L, app->getShouldRender());
			return 1;
		}

		if (field == "ticks")
		{
			lua_pushinteger(L, app->getTicks());
			return 1;
		}

		if (field == "renderer")
		{
			RendererBinding::push(L, app->getRenderer());
			return 1;
		}

		return luaL_error(L, "Uknown field for Applicatrion: %s", field.c_str());
	}

	static int setStopFlag(lua_State* L)
	{
		ApplicationPtr app = fromStack(L, 1);
		app->setShouldStop(lua_toboolean(L,3));
		return 0;
	}

	static int setRenderFlag(lua_State* L)
	{
		ApplicationPtr app = fromStack(L, 1);
		app->setShouldRender(lua_toboolean(L,3));
		return 0;
	}

	static int getRenderList(lua_State* L)
	{
		ApplicationPtr app = fromStack(L,1);
		RenderListBinding::push(L, app->getRenderList());
		return 1;
	}

	static int setRenderList(lua_State* L)
	{
		ApplicationPtr app = fromStack(L,1);
		RenderListPtr newList = RenderListBinding::fromStack(L,3);
		app->setRenderList(std::move(newList));
		return 0;
	}
};

#endif //__LB_APPLICATION_H