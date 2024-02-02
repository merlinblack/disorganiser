#include "rectangle.h"

Rectangle::Rectangle(SDL_Color color, bool fill, SDL_Rect dest) :
	color(color),
	fill(fill),
	destination(dest),
	source({0,0,0,0}),
	clip({0,0,0,0})
{
}

Rectangle::Rectangle(TexturePtr texture, int x, int y) :
	texture(texture),
	source({0,0,0,0}),
	clip({0,0,0,0})
{
	destination = {x, y, 0, 0};
}

Rectangle::Rectangle(TexturePtr texture, SDL_Rect dest, SDL_Rect src) :
	texture(texture),
	destination(dest),
	source(src),
	clip({0,0,0,0})
{
	if (destination.w && !source.w)
	{
		source = {0, 0, texture->getWidth(), texture->getHeight()};
	}
}

void Rectangle::render(const SDL_Renderer* renderer)
{
	if (texture != nullptr)
	{
		renderTexture(renderer);
	}
	else
	{
		renderRect(renderer);
	}
}

void Rectangle::renderTexture(const SDL_Renderer* renderer)
{
	if (source.w)
	{
		texture->render(renderer, &source, &destination);
	}
	else if (destination.w)
	{
		texture->render(renderer, nullptr, &destination);
	}
	else if (clip.w)
	{
		texture->render(renderer, destination.x, destination.y, &clip);
	}
	else
	{
		texture->render(renderer, destination.x, destination.y);
	}
}

void Rectangle::renderRect(const SDL_Renderer* renderer)
{
	SDL_SetRenderDrawColor(const_cast<SDL_Renderer *>(renderer), color.r, color.g, color.b, color.a);
	if (fill) 
	{
		SDL_RenderFillRect(const_cast<SDL_Renderer *>(renderer), &destination);
	}
	else
	{
		SDL_RenderDrawRect(const_cast<SDL_Renderer*>(renderer), &destination);
	}
}