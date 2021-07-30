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
	shouldStop(false),
	shouldRender(true)
{
	sdl = std::make_shared<SDL>();
	timer = std::make_shared<Timer>();
	scripts = std::make_shared<ScriptManager>();
	renderList = std::make_shared<RenderList>();
}

Application::~Application()
{
	shutdown();
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
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Could not init SDL: %s", sdl->getLastErrorMessage());
		return true;
	}

	failed = sdl->createWindow(
		"Hub Commander",
		SDL_WINDOWPOS_UNDEFINED,
		SDL_WINDOWPOS_UNDEFINED,
		800,
		480
		);

	if (failed)
	{
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Could not create window: %s", sdl->getLastErrorMessage());
		return true;
	}

	sdl->clear();
	sdl->present();

	if (onRaspberry)
	{
		SDL_ShowCursor(SDL_DISABLE);
	}

	timer->withInterval(1000)->start();

	if (scripts->loadFromFile("scripts/main.lua"))
	{
		shouldStop = true;
		return true;
	}

	font = std::make_shared<Font>("media/font.ttf", 26);

	const SDL_Renderer* renderer = sdl->getRenderer();

	TexturePtr background = Texture::createFromFile(renderer, "media/test.png");
	renderList->add(std::make_shared<Rectangle>(background, SDL_Rect({0,0,800,480})));

	SDL_Color red = {0xFF, 0x00, 0x00, 0xFF};
	TexturePtr title = font->renderTextNice(renderer, "Bu Türkçe karakterler için bir testtir.", red);
	renderList->add(std::make_shared<Rectangle>(title, 164, 164));

	TexturePtr clockTexture = font->renderTextNice(renderer, "Clock", red);
	clock = std::make_shared<Rectangle>(clockTexture, 260, 8);
	renderList->add(clock);

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
	font = nullptr;
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

	shouldRender = true;
}

void Application::render()
{
	static Uint32 prevTicks = 0;
	SDL_Color slategray = {0x70, 0x80, 0x90, 0xFF};

	std::stringstream ss;
	Uint32 ticks = SDL_GetTicks();
	ss << ticks << " diff: " << ticks - prevTicks;
	prevTicks = ticks;
	TexturePtr clockTexture = font->renderTextNice(sdl->getRenderer(), ss.str().c_str(), slategray);
	clock->setTexture(clockTexture);

	sdl->clear();
	renderList->render(sdl->getRenderer());
	sdl->present();

	shouldRender = false;
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
					SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, mooned.what());
				}
			} 
			while (SDL_PollEvent(&event));

			if (shouldRender)
			{
				render();
			}
		}
		else
		{
			SDL_Log( "There was a problem waiting for events: %s", SDL_GetError());
		}
	}
}