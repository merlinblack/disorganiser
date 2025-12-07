#include "atlas.h"

void Atlas::setTexture(TexturePtr newTexture)
{
  texture = newTexture;
}

void Atlas::setScale(float hScale, float vScale)
{
  horizontalScale = hScale;
  verticalScale = vScale;
}

std::size_t Atlas::addImage(SDL_Rect& src)
{
  list.push_back(src);
  return list.size();
}

bool Atlas::renderImage(const SDL_Renderer* renderer,
                        std::size_t index,
                        int x,
                        int y)
{
  if (list.size() < index)
    return false;

  if (!texture)
    return false;

  SDL_Rect& src = list.at(index);
  SDL_Rect dest = {x, y, (int)(src.w * horizontalScale),
                   (int)(src.h * verticalScale)};

  texture->render(renderer, &src, &dest);

  return true;
}