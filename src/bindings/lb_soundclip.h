#ifndef __SOUND_CLIP_BINDING_H
#define __SOUND_CLIP_BINDING_H

#include "LuaBinding.h"
#include "soundclip.h"

struct SoundClipBinding
    : public ManualBind::Binding<SoundClipBinding, SoundClip> {
  static constexpr const char* class_name = "Sound";

  static luaL_Reg* members()
  {
    static luaL_Reg members[] = {
        {"play",  play   },
        {"stop",  stop   },
        {nullptr, nullptr}
    };
    return members;
  }

  static int create(lua_State* L)
  {
    const char* filename = luaL_checkstring(L, -1);
    SoundClipPtr s = std::make_shared<SoundClip>(filename);
    push(L, s);
    return 1;
  }

  static int play(lua_State* L)
  {
    SoundClipPtr s = fromStack(L, 1);
    s->play(luaL_checkinteger(L, -1));
    return 0;
  }

  static int stop(lua_State* L)
  {
    SoundClipPtr s = fromStack(L, 1);
    s->stop();
    return 0;
  }
};

#endif  // __SOUND_CLIP_BINDING_H
