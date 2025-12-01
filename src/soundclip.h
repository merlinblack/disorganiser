#ifndef __SOUNDCLIP_H
#define __SOUNDCLIP_H

#include <SDL2/SDL_mixer.h>
#include <memory>

class SoundClip {
  Mix_Chunk* chunk;
  int channel;

 public:
  SoundClip() : chunk(nullptr), channel(-1) {}
  SoundClip(const char* filename);
  ~SoundClip();

  void play(int loop);
  void stop();
};

using SoundClipPtr = std::shared_ptr<SoundClip>;

#endif  // __SOUNDCLIP_H
