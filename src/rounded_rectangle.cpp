#include "rounded_rectangle.h"
#include <SDL2/SDL2_gfxPrimitives.h>

RoundedRectangle::RoundedRectangle(SDL_Color color,
                                   SDL_Rect rect,
                                   int radius,
                                   SDL_Color fillColor)
    : color(color),
      fill(true),
      destination(rect),
      radius(radius),
      fillColor(fillColor)
{
}

RoundedRectangle::RoundedRectangle(SDL_Color color, SDL_Rect rect, int radius)
    : color(color),
      fill(false),
      destination(rect),
      radius(radius),
      fillColor({0, 0, 0, 0})
{
}

void RoundedRectangle::render(const SDL_Renderer* renderer)
{
  if (fill) {
    roundedBoxRGBA(const_cast<SDL_Renderer*>(renderer), destination.x,
                   destination.y, destination.x + destination.w,
                   destination.y + destination.h, radius, fillColor.r,
                   fillColor.g, fillColor.b, fillColor.a);
  }

  roundedRectangleRGBA(const_cast<SDL_Renderer*>(renderer), destination.x,
                       destination.y, destination.x + destination.w,
                       destination.y + destination.h, radius, color.r, color.g,
                       color.b, color.a);

  SDL_SetRenderDrawBlendMode(const_cast<SDL_Renderer*>(renderer),
                             SDL_BLENDMODE_BLEND);
}