#ifndef __TEXTURE_H
#define __TEXTURE_H

#include <SDL2/SDL.h>
#include <string>
#include <memory>

class Texture
{
	SDL_Texture* texture;
	int width;
	int height;

	public:
	~Texture() { free(); }

	bool createFromFile(SDL_Renderer* renderer, const std::string& path);
	bool createFromSurface(SDL_Renderer* renderer, SDL_Surface* surface);
	void free();
	bool render(SDL_Renderer* renderer, int x, int y, const SDL_Rect* clip = nullptr);
	bool render(SDL_Renderer* renderer, const SDL_Rect* src = nullptr, const SDL_Rect* dest = nullptr);
};

using TexturePtr = std::shared_ptr<Texture>;

#endif // __TEXTURE_H
