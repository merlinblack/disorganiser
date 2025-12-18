#ifndef __SOUNDCLIP_H
#define __SOUNDCLIP_H

#include <SDL2/SDL_mixer.h>
#include <memory>

class SoundClip {
  Mix_Chunk* chunk;
  int channel;
  bool is_playing;

  static SoundClip* playing[8];

 public:
  SoundClip() : chunk(nullptr), channel(-1), is_playing(false) {}
  SoundClip(const char* filename);
  ~SoundClip();

  bool isLoaded() { return chunk != nullptr; }
  bool isPlaying() { return is_playing; }

  void play(int loop);
  void stop();

  static void channelFinishedCallback(int channel);
};

using SoundClipPtr = std::shared_ptr<SoundClip>;

#endif  // __SOUNDCLIP_H
