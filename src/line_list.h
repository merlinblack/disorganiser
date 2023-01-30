#ifndef LINE_LIST_H
#define LINE_LIST_H

#include "renderlist.h"
#include <vector>
#include <memory>
#include <SDL2/SDL.h>

class LineList : public Renderable
{
	std::vector<SDL_Point> points;
	SDL_Color color;

	public:
	void setColor(SDL_Color c) { color = c; }
	void addPoint(SDL_Point p) { points.emplace_back(p); }
	auto getPoints() { return points; }
	void clearPoints() { points.clear(); }
	
	void render(const SDL_Renderer* renderer);
};

using LineListPtr = std::shared_ptr<LineList>;

#endif // LINE_LIST_H