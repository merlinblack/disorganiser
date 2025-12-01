#include "soundclip.h"
#include <SDL2/SDL.h>
#include <SDL_mixer.h>

SoundClip::SoundClip(const char* filename)
{
  channel = -1;
  chunk = Mix_LoadWAV(filename);
  if (!chunk) {
    SDL_Log("%s", Mix_GetError());
  }
}

SoundClip::~SoundClip()
{
  stop();
  Mix_FreeChunk(chunk);
}

void SoundClip::play()
{
  channel = Mix_PlayChannel(-1, chunk, 0);
}

void SoundClip::stop()
{
  if (channel != -1) {
    Mix_HaltChannel(channel);
  }
}
