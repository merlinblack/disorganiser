#ifndef __LB_APPLICATION_H
#define __LB_APPLICATION_H

#include <unistd.h>

#include "LuaBinding.h"
#include "application.h"
#include "lb_renderlist.h"
#include "lb_renderer.h"
#include "lb_texture.h"
#include "git_versioning.h"

struct ApplicationBinding : public ManualBind::Binding<ApplicationBinding,Application>
{
	static constexpr const char* class_name = "Application";

	static ManualBind::bind_properties* properties()
	{
		static ManualBind::bind_properties properties[] = {
			{ "shouldStop", get, setStopFlag },
			{ "shouldRestart", get, setRestartFlag },
			{ "ticks", get, nullptr },
			{ "onRaspberry", get, set },
			{ "onMacMini", get, set },
			{ "renderer", get, nullptr },
			{ "width", get, set },
			{ "height", get, set },
			{ "isPictureFrame", get, set },
			{ "hasTouchScreen", get, set },
			{ "version", get, nullptr },
			{ "renderList", getRenderList, setRenderList },
			{ "overlay", getOverlay, setOverlay },
			{ "emptyTexture", get, nullptr },
			{ "textInputMode", getTextInputMode, setTextInputMode },
			{ "showCursor", nullptr, setShowCursor },
            { "hostname", getHostname, nullptr },
			{ nullptr, nullptr, nullptr }
		};
		return properties;
	}

	static int get(lua_State* L)
	{
		ApplicationPtr app = fromStack(L, 1);
		std::string field(lua_tostring(L, 2));
		
		// Roughly ordered by how often used 

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

		if (field == "emptyTexture")
		{
			TextureBinding::push(L, app->getEmptyTexture());
			return 1;
		}
		
		if (field == "width")
		{
			lua_pushinteger(L, app->getWidth());
			return 1;
		}

		if (field == "height")
		{
			lua_pushinteger(L, app->getHeight());
			return 1;
		}

		if (field == "isPictureFrame")
		{
			lua_pushboolean(L, app->getIsPictureFrame());
			return 1;
		}

		if (field == "hasTouchScreen")
		{
			lua_pushboolean(L, app->getHasTouchScreen());
			return 1;
		}

		if (field == "version")
		{
			lua_pushstring(L, GIT_REPO_VERSION_STR);
			return 1;
		}

		if (field == "shouldStop")
		{
			lua_pushboolean(L, app->getShouldStop());
			return 1;
		}

		if (field == "shouldRestart")
		{
			lua_pushboolean(L, app->getShouldRestart());
			return 1;
		}

		if (field == "onRaspberry")
		{
			lua_pushboolean(L, app->getOnRaspberry());
			return 1;
		}

		if (field == "onMacMini")
		{
			lua_pushboolean(L, app->getOnMacMini());
			return 1;
		}

		return luaL_error(L, "Uknown field for Application: %s", field.c_str());
	}

	static int set(lua_State* L)
	{
		ApplicationPtr app = fromStack(L, 1);
		std::string field(lua_tostring(L, 2));

		if (field == "width")
		{
			app->setWidth(lua_tointeger(L, 3));
			return 0;
		}
	
		if (field == "height")
		{
			app->setHeight(lua_tointeger(L, 3));
			return 0;
		}
	
		if (field == "isPictureFrame")
		{
			app->setIsPictureFrame(lua_toboolean(L, 3));
			return 0;
		}
	
		if (field == "hasTouchScreen")
		{
			app->setHasTouchScreen(lua_toboolean(L, 3));
			return 0;
		}
	
		if (field == "onRaspberry")
		{
			app->setOnRaspberry(lua_toboolean(L, 3));
			return 0;
		}

		if (field == "onMacMini")
		{
			app->setOnMacMini(lua_toboolean(L, 3));
			return 0;
		}

		return luaL_error(L, "Uknown field for Application: %s", field.c_str());
	}

	static int setStopFlag(lua_State* L)
	{
		ApplicationPtr app = fromStack(L, 1);
		app->setShouldStop(lua_toboolean(L,3));
		return 0;
	}

	static int setRestartFlag(lua_State* L)
	{
		ApplicationPtr app = fromStack(L, 1);
		app->setShouldRestart(lua_toboolean(L,3));
		return 0;
	}

	static int setShowCursor(lua_State* L)
	{
		ApplicationPtr app = fromStack(L, 1);
		app->setShowCursor(lua_toboolean(L,3));
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

	static int getOverlay(lua_State* L)
	{
		ApplicationPtr app = fromStack(L,1);
		RenderListBinding::push(L, app->getOverlay());
		return 1;
	}

	static int setOverlay(lua_State* L)
	{
		ApplicationPtr app = fromStack(L,1);
		RenderListPtr newList = RenderListBinding::fromStack(L,3);
		app->setOverlay(std::move(newList));
		return 0;
	}

	static int getTextInputMode(lua_State* L)
	{
		lua_pushboolean(L, SDL_IsTextInputActive());
		return 1;
	}

	static int setTextInputMode(lua_State* L)
	{
		ApplicationPtr app = fromStack(L,1);
		bool enable = luaL_opt(L, lua_toboolean, 2, true);
		app->setTextInputMode(enable);
		return 0;
	}

#define HOSTNAMESIZE 256
    static int getHostname(lua_State* L)
    {
        char buffer[HOSTNAMESIZE];

        if( gethostname(buffer, HOSTNAMESIZE) )
        {
            return luaL_error(L, "Error getting hostname.");
        }

        lua_pushstring(L, buffer);

        return 1;
    }
};

#endif //__LB_APPLICATION_H
