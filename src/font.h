#ifndef __FONT_H
#define __FONT_H

#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <string>
#include <memory>

#include "texture.h"

class Font
{
	TTF_Font* font;
	bool failed;
	std::string lastErrorMessage;

	public:
	Font(const std::string& path, int size);

	~Font() { TTF_CloseFont(font); SDL_Log("~Font %lx\n", (unsigned long)this); }

	bool hasFailed() { return failed; }
	const std::string& getLastErrorMessage() { return lastErrorMessage; }
	
	int lineHeight() { return TTF_FontLineSkip(font); }

	bool sizeText(const std::string& text, int* width, int *height);
	TexturePtr renderTextQuick(const SDL_Renderer* renderer, const std::string& text, SDL_Color color);
	TexturePtr renderTextNice(const SDL_Renderer* renderer, const std::string& text, SDL_Color color);
};

using FontPtr = std::shared_ptr<Font>;

#endif //  __FONT_H
