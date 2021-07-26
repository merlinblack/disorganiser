#ifndef __APPLICATION_H 
#define __APPLICATION_H 

#include "sdl.h"
#include "font.h"
#include "texture.h"
#include "timer.h"
#include "renderlist.h"
#include "rectangle.h"
#include "script_manager.h"
#include <memory>

class Application
{
	SDLptr sdl;
	bool onRaspberry;
	bool shouldStop;
	bool shouldRender;

	TimerPtr timer;

	FontPtr font;
	RenderListPtr renderList;
	RectanglePtr clock;

	public:
	Application();
	~Application();

	/**
	 * \param onRaspbberry_ configure for my Raspberry Pi with touchscreen
	 */
	bool init(bool onRaspberry_);
	void shutdown();

	void handleKeyUp(const SDL_Event &event);
	void handleMouse(const SDL_Event &event);
	void handleTouch(const SDL_Event &event);
	void handleTimer(const SDL_Event &event);
	void render();
	void dispatchEvent(const SDL_Event& event);
	void eventLoop();
};

using ApplicationPtr = std::shared_ptr<Application>;

#endif // __APPLICATION_H 