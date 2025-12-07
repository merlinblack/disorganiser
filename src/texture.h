#ifndef __TEXTURE_H
#define __TEXTURE_H

#include <SDL2/SDL.h>
#include <memory>
#include <string>

class Texture;

using TexturePtr = std::shared_ptr<Texture>;

class Texture {
  SDL_Texture* texture;
  int width;
  int height;

 public:
  ~Texture()
  {
    free();
    SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, "~Texture %lx\n",
                 (unsigned long)this);
  }

  static TexturePtr createFromFile(const SDL_Renderer* renderer,
                                   const std::string& path);
  bool createFromSurface(const SDL_Renderer* renderer, SDL_Surface* surface);
  bool createEmpty(const SDL_Renderer* renderer);
  void free();
  bool render(const SDL_Renderer* renderer,
              int x,
              int y,
              const SDL_Rect* clip = nullptr);
  bool render(const SDL_Renderer* renderer,
              const SDL_Rect* src = nullptr,
              const SDL_Rect* dest = nullptr);

  int getWidth() { return width; }
  int getHeight() { return height; }
};

#endif  // __TEXTURE_H
