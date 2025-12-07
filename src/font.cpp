#include "font.h"
#include <SDL_log.h>
#include <memory>
#include "texture.h"

Font::Font(const std::string& path, int size) : font(nullptr), failed(false)
{
  font = TTF_OpenFont(path.c_str(), size);
  if (!font) {
    failed = true;
    lastErrorMessage = TTF_GetError();
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "%s", lastErrorMessage.c_str());
  }
}

std::pair<int, int> Font::sizeText(const std::string& text)
{
  SDL_assert(font != nullptr);
  int width, height;
  if (TTF_SizeUTF8(font, text.c_str(), &width, &height)) {
    lastErrorMessage = TTF_GetError();
    return {0, 0};
  }
  return {width, height};
}

TexturePtr Font::renderTextQuick(const SDL_Renderer* renderer,
                                 const std::string& text,
                                 SDL_Color color)
{
  SDL_assert(font != nullptr);
  SDL_Surface* renderedSurface =
      TTF_RenderUTF8_Solid(font, text.c_str(), color);
  if (renderedSurface) {
    TexturePtr renderedTexture = std::make_shared<Texture>();
    renderedTexture->createFromSurface(renderer, renderedSurface);
    SDL_FreeSurface(renderedSurface);
    return renderedTexture;
  }
  return nullptr;
}

TexturePtr Font::renderTextNice(const SDL_Renderer* renderer,
                                const std::string& text,
                                SDL_Color color)
{
  SDL_assert(font != nullptr);
  SDL_Surface* renderedSurface =
      TTF_RenderUTF8_Blended(font, text.c_str(), color);
  if (renderedSurface) {
    TexturePtr renderedTexture = std::make_shared<Texture>();
    renderedTexture->createFromSurface(renderer, renderedSurface);
    SDL_FreeSurface(renderedSurface);
    return renderedTexture;
  }
  return nullptr;
}
