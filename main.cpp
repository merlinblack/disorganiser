#include "sdl.h"
#include <stdio.h>
#include <memory>

int main(int argc, char *argv[])
{
    SDLptr sdl = std::make_shared<SDL>();
    
    sdl
    //->withFullscreenDesktop()
    ->withVideo()
    ->withTimer()
    ->withJPG()
    ->withPNG()
    ->init();

    sdl->createWindow(
        "Hub Commander", 
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        800,
        480
        );

    TexturePtr alara = sdl->createTextureFromFile("media/picture.jpg");

    sdl->clear();

    sdl->renderTexture(alara);

    SDL_Rect clip = { 345, 350, 50, 50 };
    sdl->renderTexture(alara, 740, 40, &clip);

    sdl->present();

    SDL_Delay(5000);

    sdl->shutdown();

    return 0;
}
