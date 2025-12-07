#ifndef ROUNDED_RECTANGLE_H
#define ROUNDED_RECTANGLE_H

#include <SDL2/SDL.h>
#include <memory>
#include "renderlist.h"

class RoundedRectangle : public Renderable {
  SDL_Rect destination;
  SDL_Color color;
  SDL_Color fillColor;
  bool fill;
  int radius;

 public:
  virtual ~RoundedRectangle()
  {
    SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, "~RoundedRectangle %lx\n",
                 (unsigned long)this);
  }
  RoundedRectangle(SDL_Color color,
                   SDL_Rect dest,
                   int radius,
                   SDL_Color fillColor);
  RoundedRectangle(SDL_Color color, SDL_Rect dest, int radius);

  void setDest(SDL_Rect dest) { destination = dest; }
  const SDL_Rect& getDest() { return destination; }
  void setColor(SDL_Color _color) { color = _color; }
  void setFillColor(SDL_Color _color) { fillColor = _color; }
  void setFill(bool _fill) { fill = _fill; }
  void setRadius(int _radius) { radius = _radius; }

  void render(const SDL_Renderer* renderer);
};

using RoundedRectanglePtr = std::shared_ptr<RoundedRectangle>;

#endif  // ROUNDED_RECTANGLE_H
