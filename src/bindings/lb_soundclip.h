#ifndef __SOUND_CLIP_BINDING_H
#define __SOUND_CLIP_BINDING_H

#include <SDL_mixer.h>
#include "LuaBinding.h"
#include "lauxlib.h"
#include "lua.h"
#include "soundclip.h"

struct SoundClipBinding
    : public ManualBind::Binding<SoundClipBinding, SoundClip> {
  static constexpr const char* class_name = "Sound";

  static ManualBind::bind_properties* properties()
  {
    static ManualBind::bind_properties properties[] = {
        {"playing", getIsPlaying, nullptr},
        {nullptr,   nullptr,      nullptr}
    };
    return properties;
  }

  static luaL_Reg* members()
  {
    static luaL_Reg members[] = {
        {"play",  play   },
        {"stop",  stop   },
        {nullptr, nullptr}
    };
    return members;
  }

  static int getIsPlaying(lua_State* L)
  {
    SoundClipPtr sound = fromStack(L, 1);
    lua_pushboolean(L, sound->isPlaying());

    return 1;
  }

  static int create(lua_State* L)
  {
    const char* filename = luaL_checkstring(L, -1);
    SoundClipPtr sound = std::make_shared<SoundClip>(filename);

    if (sound->isLoaded()) {
      push(L, sound);
    }
    else {
      lua_pushnil(L);
    }
    return 1;
  }

  static int play(lua_State* L)
  {
    SoundClipPtr sound = fromStack(L, 1);
    int volume = luaL_opt(L, lua_tointeger, 2, MIX_MAX_VOLUME);
    int loop = luaL_opt(L, lua_tointeger, 3, 0);
    sound->play(volume, loop);
    return 0;
  }

  static int stop(lua_State* L)
  {
    SoundClipPtr sound = fromStack(L, 1);
    sound->stop();
    return 0;
  }
};

#endif  // __SOUND_CLIP_BINDING_H
