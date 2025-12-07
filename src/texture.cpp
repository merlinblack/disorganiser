#include "texture.h"
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <string>

/**
 * \note static member function
 */
TexturePtr Texture::createFromFile(const SDL_Renderer* renderer,
                                   const std::string& path)
{
  TexturePtr texture = std::make_shared<Texture>();

  SDL_Surface* loadedSurface = IMG_Load(path.c_str());
  if (loadedSurface) {
    texture->createFromSurface(renderer, loadedSurface);
    SDL_FreeSurface(loadedSurface);
  }
  else {
    SDL_Log(SDL_GetError());
  }

  return std::move(texture);
}

bool Texture::createFromSurface(const SDL_Renderer* renderer,
                                SDL_Surface* surface)
{
  free();
  width = surface->w;
  height = surface->h;
  texture = SDL_CreateTextureFromSurface(const_cast<SDL_Renderer*>(renderer),
                                         surface);
  if (!texture) {
    SDL_Log(SDL_GetError());
  }
  return texture == nullptr;
}

bool Texture::createEmpty(const SDL_Renderer* const_renderer)
{
  free();
  width = 1;
  height = 1;

  SDL_Renderer* renderer = const_cast<SDL_Renderer*>(const_renderer);

  texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888,
                              SDL_RENDERER_TARGETTEXTURE, 1, 1);

  if (!texture) {
    return true;
  }

  SDL_SetRenderDrawColor(renderer, 0, 0, 0, 0);
  SDL_SetTextureBlendMode(texture, SDL_BLENDMODE_BLEND);
  SDL_SetRenderTarget(renderer, texture);
  SDL_RenderClear(renderer);
  SDL_SetRenderTarget(renderer, nullptr);

  return false;
}

void Texture::free()
{
  if (texture) {
    SDL_DestroyTexture(texture);
  }
  texture = nullptr;
}

bool Texture::render(const SDL_Renderer* renderer,
                     int x,
                     int y,
                     const SDL_Rect* clip)
{
  SDL_Rect dest = {x, y, width, height};

  if (clip) {
    dest.w = clip->w < width ? clip->w : width;
    dest.h = clip->h < height ? clip->h : height;
  }

  return SDL_RenderCopy(const_cast<SDL_Renderer*>(renderer), texture, clip,
                        &dest) == 0;
}

bool Texture::render(const SDL_Renderer* renderer,
                     const SDL_Rect* src,
                     const SDL_Rect* dest)
{
  return SDL_RenderCopy(const_cast<SDL_Renderer*>(renderer), texture, src,
                        dest) == 0;
}