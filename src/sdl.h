#ifndef __SDL_H
#define __SDL_H

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <string>
#include <memory>

#include "texture.h"
#include "font.h"

class SDL
{
	SDL_Window* window;
	SDL_Renderer* renderer;
	int initFlags;
	int windowFlags;
	int imageFlags;
	bool failed;
	std::string lastErrorMessage;

	public:
	SDL() :
		window(nullptr), 
		initFlags(0), 
		windowFlags(0), 
		failed(false) 
		{}
	~SDL() { shutdown(); }

	bool init();
	void shutdown();

	SDL* withVideo() { initFlags += SDL_INIT_VIDEO; return this; }
	SDL* withTimer() { initFlags += SDL_INIT_TIMER; return this; }
	SDL* withFullscreen() { windowFlags += SDL_WINDOW_FULLSCREEN; return this; }
	SDL* withFullscreenDesktop() { windowFlags += SDL_WINDOW_FULLSCREEN_DESKTOP; return this; }
	SDL* withJPG() { imageFlags += IMG_INIT_JPG; return this; }
	SDL* withPNG() { imageFlags += IMG_INIT_PNG; return this; }
	SDL* withTIF() { imageFlags += IMG_INIT_TIF; return this; }
	SDL* withWEBP() { imageFlags += IMG_INIT_WEBP; return this; }

	bool hasFailed() { return failed; }
	const std::string& getLastErrorMessage() { return lastErrorMessage; }

	bool createWindow(std::string title, int x, int y, int width, int height);

	TexturePtr createTextureFromFile(const std::string& path);
	TexturePtr renderTextQuick(FontPtr font, const std::string& text, SDL_Color color);
	TexturePtr renderTextNice(FontPtr font, const std::string& text, SDL_Color color);
	bool renderTexture( TexturePtr texture, int x, int y, const SDL_Rect* clip = nullptr);
	bool renderTexture( TexturePtr texture, const SDL_Rect* src = nullptr, const SDL_Rect* dest = nullptr);

    void clear() { SDL_RenderClear(renderer); }
	void present() { SDL_RenderPresent(renderer); }
};

using SDLptr= std::shared_ptr<SDL>;

#endif // __SDL_H