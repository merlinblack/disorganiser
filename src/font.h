#ifndef __FONT_H
#define __FONT_H

#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <string>
#include <memory>
#include <tuple>

#include "texture.h"

class Font
{
	TTF_Font* font;
	bool failed;
	std::string lastErrorMessage;

	public:
	Font(const std::string& path, int size);

	~Font() { if (font) { TTF_CloseFont(font); } SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, "~Font %lx\n", (unsigned long)this); }

	bool hasFailed() { return failed; }
	const std::string& getLastErrorMessage() { return lastErrorMessage; }
	
	int lineHeight() { return font ? TTF_FontLineSkip(font) : 0; }

	std::pair<int,int> sizeText(const std::string& text);
	TexturePtr renderTextQuick(const SDL_Renderer* renderer, const std::string& text, SDL_Color color);
	TexturePtr renderTextNice(const SDL_Renderer* renderer, const std::string& text, SDL_Color color);
};

using FontPtr = std::shared_ptr<Font>;

#endif //  __FONT_H
