#include "texture.h"
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <string>

/**
 * \note static member function
 */
TexturePtr Texture::createFromFile(const SDL_Renderer* renderer, const std::string& path)
{
	TexturePtr texture = std::make_shared<Texture>();

	SDL_Surface* loadedSurface = IMG_Load(path.c_str());
	if (loadedSurface)
	{
		texture->createFromSurface(renderer, loadedSurface);
		SDL_FreeSurface(loadedSurface);
	}

	return std::move(texture);
}

bool Texture::createFromSurface(const SDL_Renderer* renderer, SDL_Surface* surface)
{
	free();
	width = surface->w;
	height = surface->h;
	texture = SDL_CreateTextureFromSurface(const_cast<SDL_Renderer*>(renderer), surface);
	return texture == nullptr;
}

void Texture::free()
{
	SDL_DestroyTexture(texture);
	texture = nullptr;
}

bool Texture::render(const SDL_Renderer *renderer, int x, int y, const SDL_Rect *clip)
{
	SDL_Rect dest = { x, y, width, height };

	if (clip)
	{
		dest.w = clip->w;
		dest.h = clip->h;
	}

	return SDL_RenderCopy(const_cast<SDL_Renderer*>(renderer), texture, clip, &dest) == 0;
}

bool Texture::render(const SDL_Renderer *renderer, const SDL_Rect* src, const SDL_Rect* dest)
{
	return SDL_RenderCopy(const_cast<SDL_Renderer*>(renderer), texture, src, dest) == 0;
}