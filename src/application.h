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

#define WINDOW_WIDTH 800
#define WINDOW_HEIGHT 480

using ApplicationPtr = std::shared_ptr<Application>;

class Application
{
	SDLptr sdl;
	bool onRaspberry;
	bool shouldStop;

	TimerPtr timer;
	ScriptManagerPtr scripts;

	RenderListPtr renderList;
	RenderListPtr overlayRenderList;
	TexturePtr emptyTexture;

	public:
	Application();
	virtual ~Application();

	/**
	 * \param onRaspbberry_ configure for my Raspberry Pi with touchscreen
	 */
	bool init(bool onRaspberry_);
	void shutdown();

	void handleTextInput(const SDL_Event &event);
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
	int getTicks() { return SDL_GetTicks(); }
	RenderListPtr getRenderList() { return renderList; }
	RenderListPtr getOverlay() { return overlayRenderList; }
	void setRenderList(RenderListPtr newList) { renderList = newList; }
	void setOverlay(RenderListPtr newList) { overlayRenderList = newList; }
	const SDL_Renderer* getRenderer() { return sdl->getRenderer(); }
	void setTextInputMode(bool enable);

	TexturePtr getEmptyTexture();

	void initLuaApp(ApplicationPtr app);
};

#endif // __APPLICATION_H 