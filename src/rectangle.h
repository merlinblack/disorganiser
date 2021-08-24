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
	SDL_Rect clip;
	TexturePtr texture;
	SDL_Color color;
	bool fill;

	void renderTexture(const SDL_Renderer* renderer);
	void renderRect(const SDL_Renderer* renderer);

	public:
	virtual ~Rectangle() { SDL_Log("~Rectangle %lx\n", (unsigned long)this); }
	Rectangle(SDL_Color color, bool fill, SDL_Rect dest);
	Rectangle(TexturePtr texture, int x, int y);
	Rectangle(TexturePtr texture, SDL_Rect dest, SDL_Rect src = {0,0,0,0});

	void setTexture(TexturePtr newTexture) { texture = newTexture; }
	TexturePtr getTexture() { return texture; }

	void setDest(SDL_Rect dest) { destination = dest; }
	const SDL_Rect&  getDest() { return destination; }
	void setSource(SDL_Rect src) { source = src; }
	const SDL_Rect&  getSource() { return source; }
	void setClip(SDL_Rect _clip) { clip = _clip; }
	void setColor(SDL_Color _color) { color = _color; }
	void setFill(bool _fill) { fill = _fill; }

	void render(const SDL_Renderer* renderer);
};

using RectanglePtr = std::shared_ptr<Rectangle>;

#endif //RECTANGLE_H
