#include "texture.h"
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <string>

bool Texture::createFromFile(SDL_Renderer* renderer, const std::string& path)
{
	free();

	SDL_Surface* loadedSurface = IMG_Load(path.c_str());
	if (loadedSurface)
	{
		width = loadedSurface->w;
		height = loadedSurface->h;
		texture = SDL_CreateTextureFromSurface(renderer, loadedSurface);
	}

	return texture != nullptr;
}

void Texture::free()
{
	SDL_DestroyTexture(texture);
	texture = nullptr;
}

bool Texture::render(SDL_Renderer *renderer, int x, int y, const SDL_Rect *clip)
{
	SDL_Rect dest = { x, y, width, height };

	if (clip)
	{
		dest.w = clip->w;
		dest.h = clip->h;
	}

	return SDL_RenderCopy(renderer, texture, clip, &dest) == 0;
}

bool Texture::render(SDL_Renderer *renderer, const SDL_Rect* src, const SDL_Rect* dest)
{
	return SDL_RenderCopy(renderer, texture, src, dest) == 0;
}