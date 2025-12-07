#include "timer.h"

bool Timer::start()
{
  id = SDL_AddTimer(interval, callback, this);
  return id != 0;
}

bool Timer::stop()
{
  bool success = true;
  if (id) {
    if (SDL_RemoveTimer(id)) {
      id = 0;
    }
    else {
      success = false;
    }
  }
  return success;
}

Uint32 Timer::callback(Uint32 interval, void* param)
{
  Timer* self = (Timer*)param;

  SDL_Event event;
  event.type = SDL_USEREVENT;
  event.user = self->userEvent;

  SDL_PushEvent(&event);

  return self->interval;
}