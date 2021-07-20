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
		return false;
	}

	failed = !(IMG_Init(imageFlags) & imageFlags);
	if (failed)
	{
		lastErrorMessage = IMG_GetError();
		return false;
	}

	failed = (bool)TTF_Init();
	if (failed)
	{
		lastErrorMessage = TTF_GetError();
		return false;
	}

	return true;
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
		return false;
	}

	renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
	if (!renderer)
	{
		failed = true;
		lastErrorMessage = SDL_GetError();
		return false;
	}

	SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);

	return true;
}

TexturePtr SDL::createTextureFromFile(const std::string& path)
{
	TexturePtr newTexture = std::make_shared<Texture>();

	if (newTexture->createFromFile(renderer, path))
	{
		return newTexture;
	}

	return nullptr;
}

bool SDL::renderTexture(TexturePtr texture, int x, int y, const SDL_Rect* clip)
{
	return texture->render(renderer, x, y, clip);
}

bool SDL::renderTexture(TexturePtr texture, const SDL_Rect* src, const SDL_Rect* dest)
{
	return texture->render(renderer, src, dest);
}