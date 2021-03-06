#include "application.h"
#include "lb_application.h"
#include "sdl.h"
#include "timer.h"
#include "rectangle.h"
#include "LuaRef.h"
#include <stdio.h>
#include <memory>
#include <sstream>

using ManualBind::LuaRef;

Application::Application() : 
	onRaspberry(false),
	shouldStop(false)
{
	sdl = std::make_shared<SDL>();
	timer = std::make_shared<Timer>();
	scripts = std::make_shared<ScriptManager>();
	renderList = std::make_shared<RenderList>();
}

Application::~Application()
{
}

bool Application::init(bool onRaspberry_ = false)
{
	onRaspberry = onRaspberry_;

	bool failed;
	if (onRaspberry)
		sdl->withFullscreenDesktop();

	failed = sdl
		->withVideo()
		->withTimer()
		->withJPG()
		->withPNG()
		->init();

	if (failed)
	{
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Could not init SDL: %s", sdl->getLastErrorMessage().c_str());
		return true;
	}

	failed = sdl->createWindow(
		"Disorganiser",
		SDL_WINDOWPOS_UNDEFINED,
		SDL_WINDOWPOS_UNDEFINED,
		WINDOW_WIDTH,
		WINDOW_HEIGHT
		);

	if (failed)
	{
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Could not create window: %s", sdl->getLastErrorMessage().c_str());
		return true;
	}

	sdl->clear();
	sdl->present();

	if (onRaspberry)
	{
		SDL_ShowCursor(SDL_DISABLE);
	}

	timer->withInterval(100)->start();

	if (scripts->loadFromFile("scripts/init.lua"))
	{
		shouldStop = true;
		return true;
	}

	return false;
}

void Application::initLuaApp(ApplicationPtr app)
{
	lua_State* L = scripts->getMainLuaState();
	ApplicationBinding::push(L, app);
	lua_setglobal(L, "app");
}

void Application::shutdown()
{
	scripts->shutdown();
	timer->stop();
	sdl->shutdown();
}

void Application::handleKeyUp(const SDL_Event& event)
{
	switch (event.key.keysym.sym)
	{
		case SDLK_ESCAPE:
			shouldStop = true;
			break;
		default:
			LuaRef keyUp = scripts->getGlobal("handleKeyUp");
			if (keyUp.isFunction())
			{
				keyUp(event.key.keysym.sym);
			}
			break;
	}
}

void Application::handleMouse(const SDL_Event& event)
{
	LuaRef mouse = scripts->getGlobal("handleMouse");
	if (mouse.isFunction())
	{
		switch (event.type) {
			case SDL_MOUSEBUTTONDOWN:
			case SDL_MOUSEBUTTONUP:
				mouse(
					event.type,
					event.button.x,
					event.button.y,
					event.button.button,
					event.button.state,
					event.button.clicks
				);
				break;
		}
	}
}

void Application::handleTouch(const SDL_Event& event)
{
	LuaRef touch = scripts->getGlobal("handleTouch");
	if (touch.isFunction())
	{
		touch(
			event.type,
			event.tfinger.x,
			event.tfinger.y,
			event.tfinger.dx,
			event.tfinger.dy
		);
	}
}

void Application::handleTimer(const SDL_Event& event)
{
	/**
	 * Run next task coroutine
	 */
	scripts->resume();
}

void Application::render()
{
	if (renderList->shouldRender())
	{
		sdl->clear();
		renderList->render(sdl->getRenderer());
		sdl->present();
	}
}

void Application::dispatchEvent(const SDL_Event& event)
{
	switch (event.type)
	{
	case SDL_QUIT:
		shouldStop = true;
		break;
	/*
	TODO: figure out what window event we should trigger rendering on, after being minimized.
	case SDL_WINDOWEVENT_SHOWN:
		shouldRender = true;
		break;
	*/
	case SDL_KEYUP:
		handleKeyUp(event);
		break;
	case SDL_MOUSEBUTTONDOWN:
	case SDL_MOUSEBUTTONUP:
	case SDL_MOUSEMOTION:
	case SDL_MOUSEWHEEL:
		handleMouse(event);
		break;
	case SDL_FINGERDOWN:
	case SDL_FINGERUP:
	case SDL_FINGERMOTION:
		handleTouch(event);
		break;
	case SDL_USEREVENT:
		handleTimer(event);
		break;
	default:
		//PrintEvent(&event);
		break;
	}
}

void Application::eventLoop()
{
	SDL_Event event;

	while (!shouldStop)
	{
		if (SDL_WaitEvent(&event))
		{
			do 
			{
				try 
				{
					dispatchEvent(event);
				}
				catch (ManualBind::LuaException& mooned)
				{
					SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "%s", mooned.what());
				}
			} 
			while (SDL_PollEvent(&event));

			render();
		}
		else
		{
			SDL_Log( "There was a problem waiting for events: %s", SDL_GetError());
		}
	}
}

// Get a placeholder texture that will soon be replaced.
TexturePtr Application::getEmptyTexture()
{
	if (!emptyTexture)
	{
		emptyTexture = std::make_shared<Texture>();
		emptyTexture->createEmpty(sdl->getRenderer());
	}

	return emptyTexture;
}
