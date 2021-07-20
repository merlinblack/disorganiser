#include "sdl.h"
#include <stdio.h>

SDL sdl;

int main(int argc, char *argv[])
{
    sdl.withVideo()
    ->withTimer()
    ->withJPG()
    ->withPNG()
    ->init();

    sdl.createWindow(
        "Hub Commander", 
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        800,
        480
        );

    SDL_Delay(2000);

    sdl.shutdown();
    
    return 0;
}
