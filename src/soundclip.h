#ifndef __SOUNDCLIP_H
#define __SOUNDCLIP_H

#include <SDL2/SDL_mixer.h>

class SoundClip {
  Mix_Chunk* chunk;
  int channel;

 public:
  SoundClip() : chunk(nullptr), channel(-1) {}
  SoundClip(const char* filename);
  ~SoundClip();

  void play();
  void stop();
};

#endif  // __SOUNDCLIP_H
