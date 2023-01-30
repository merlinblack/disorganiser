#include "line_list.h"

void LineList::render(const SDL_Renderer* const_renderer)
{
	SDL_Renderer *renderer = const_cast<SDL_Renderer *>(const_renderer);

	SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a);
	SDL_RenderDrawLines(renderer, points.data(), points.size());
}