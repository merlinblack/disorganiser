#include "sdl.h"
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>

bool SDL::init()
{
	failed = (bool)SDL_Init(initFlags);
	if (failed)
	{
		lastErrorMessage = SDL_GetError();
		return true;
	}

	failed = !(IMG_Init(imageFlags) & imageFlags);
	if (failed)
	{
		lastErrorMessage = IMG_GetError();
		return true;
	}

	failed = (bool)TTF_Init();
	if (failed)
	{
		lastErrorMessage = TTF_GetError();
		return true;
	}

	return false;
}

void SDL::shutdown()
{
	SDL_DestroyRenderer(renderer);
	renderer = nullptr;
	window = nullptr;
	failed = false;
	initFlags = 0;
	windowFlags = 0;
	imageFlags = 0;
	TTF_Quit();
	IMG_Quit();
	SDL_Quit();
}

bool SDL::createWindow(std::string title, int x, int y, int width, int height)
{
	window = SDL_CreateWindow(title.c_str(), x, y, width, height, windowFlags);
	if (!window)
	{
		failed = true;
		lastErrorMessage = SDL_GetError();
		return failed;
	}

	renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
	if (!renderer)
	{
		failed = true;
		lastErrorMessage = SDL_GetError();
		return failed;
	}

	SDL_SetRenderDrawColor(renderer, 0x13, 0x45, 0x8a, 0xff);
	SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);

	return failed;
}