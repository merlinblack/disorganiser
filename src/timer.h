#ifndef __TIMER_H
#define __TIMER_H

#include <SDL2/SDL.h>
#include <memory>

/**
 * \brief Periodically pushes an user event to the event queue.
 **/
class Timer {
  SDL_TimerID id;
  Uint32 interval;
  SDL_UserEvent userEvent;

 public:
  Timer() : id(0), interval(0) { userEvent.type = SDL_USEREVENT; }
  ~Timer() { stop(); }

  bool start();
  bool stop();

  Timer* withInterval(Uint32 newInterval)
  {
    interval = newInterval;
    return this;
  }
  Timer* withUserEvent(const SDL_UserEvent& newUserEvent)
  {
    userEvent = newUserEvent;
    return this;
  }

  static Uint32 callback(Uint32 interval, void* param);
  friend Uint32 callback(Uint32 interval, void* param);
};

using TimerPtr = std::shared_ptr<Timer>;

#endif  // __TIMER_H