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

class Application;

using ApplicationPtr = std::shared_ptr<Application>;

class Application
{
	SDLptr sdl;
	bool onRaspberry;
	bool shouldStop;
	bool shouldRender;

	TimerPtr timer;
	ScriptManagerPtr scripts;

	RenderListPtr renderList;

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

	/**
	 * Allow Lua to get/set these
	 */
	bool getShouldStop() { return shouldStop; }
	void setShouldStop(bool val) { shouldStop = val; }
	bool getShouldRender() { return shouldRender; }
	void setShouldRender(bool val) { shouldRender = val; }
	int getTicks() { return SDL_GetTicks(); }
	RenderListPtr getRenderList() { return renderList; }
	void setRenderList(RenderListPtr newList) { renderList = newList; }
	const SDL_Renderer* getRenderer() { return sdl->getRenderer(); }

	void initLuaApp(ApplicationPtr app);
};

#endif // __APPLICATION_H 