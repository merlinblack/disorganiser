#ifndef RECTANGLE_H
#define RECTANGLE_H

#include "renderlist.h"
#include "texture.h"
#include <SDL2/SDL.h>
#include <memory>

class Rectangle : public Renderable
{
	SDL_Rect destination;
	SDL_Rect source;
	TexturePtr texture;
	SDL_Color color;
	bool fill;

	void renderTexture(const SDL_Renderer* renderer);
	void renderRect(const SDL_Renderer* renderer);

	public:
	Rectangle(SDL_Color color, bool fill, SDL_Rect dest);
	Rectangle(TexturePtr texture, int x, int y);
	Rectangle(TexturePtr texture, SDL_Rect dest, SDL_Rect src = {0,0,0,0});

	void setTexture(TexturePtr newTexture) { texture = newTexture; }

	void render(const SDL_Renderer* renderer);
};

using RectanglePtr = std::shared_ptr<Rectangle>;

#endif //RECTANGLE_H