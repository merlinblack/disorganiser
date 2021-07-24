#include "application.h"
#include "sdl.h"
#include "timer.h"
#include <stdio.h>
#include <memory>
#include <sstream>

Application::Application() : 
	onRaspberry(false),
	shouldStop(false),
	shouldRender(true)
{
	sdl = std::make_shared<SDL>();
	timer = std::make_shared<Timer>();
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

	if (onRaspberry)
	{
		SDL_ShowCursor(SDL_DISABLE);
	}

	timer->withInterval(1000)->start();

    font = std::make_shared<Font>("media/font.ttf", 16);
    background = sdl->createTextureFromFile("media/picture.jpg");
    SDL_Color yellow = {0xFF, 0xFF, 0x00, 0xFF};
    title = sdl->renderTextNice(font, "Bu Türkçe karakterler için bir testtir.", yellow);

	return false;
}

void Application::shutdown()
{
	timer->stop();
	background = nullptr;
	title = nullptr;
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
    }
}

void Application::handleMouse(const SDL_Event& event)
{

}

void Application::handleTouch(const SDL_Event& event)
{
    shouldStop = true;
}

void Application::handleTimer(const SDL_Event& event)
{
    shouldRender = true;
}

void Application::render()
{
    static Uint32 prevTicks = 0;
    SDL_Color black = {0x00, 0x00, 0x00, 0xFF};
    SDL_Color slategray = {0x70, 0x80, 0x90, 0xFF};

    std::stringstream ss;
    Uint32 ticks = SDL_GetTicks();
    ss << "Ticks: " << ticks << " diff: " << ticks - prevTicks;
    prevTicks = ticks;
    TexturePtr clock = sdl->renderTextNice(font, ss.str().c_str(), slategray);

    sdl->clear();

    sdl->renderTexture(background);
    sdl->renderTexture(title, 32, 400);
    sdl->renderTexture(clock, 50, 150);

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
				dispatchEvent(event);
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