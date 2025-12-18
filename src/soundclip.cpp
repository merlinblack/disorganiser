#include "soundclip.h"
#include <SDL2/SDL.h>
#include <SDL_mixer.h>

SoundClip* SoundClip::playing[8] = {nullptr};

SoundClip::SoundClip(const char* filename)
{
  SDL_Log("Loading sound file: %s", filename);
  channel = -1;
  is_playing = false;
  chunk = Mix_LoadWAV(filename);
  if (!chunk) {
    SDL_Log("%s", Mix_GetError());
  }
}

SoundClip::~SoundClip()
{
  Mix_FreeChunk(chunk);
}

void SoundClip::play(int loop)
{
  channel = Mix_PlayChannel(-1, chunk, loop);
  if (channel == -1) {
    SDL_Log("No available sound channels left");
    return;  // No available channel
  }
  playing[channel] = this;
  is_playing = true;
  Mix_ChannelFinished(channelFinishedCallback);
}

void SoundClip::stop()
{
  if (channel != -1) {
    Mix_HaltChannel(channel);
  }
}

// Static
void SoundClip::channelFinishedCallback(int channel)
{
  SDL_Log("Channel %d has finished playing", channel);
  playing[channel]->is_playing = false;
  playing[channel]->channel = -1;
  playing[channel] = nullptr;
}
