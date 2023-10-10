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

#define MACMINI
//#define RASPBERRYPI

#ifdef MACMINI
#define WINDOW_WIDTH 600
#define WINDOW_HEIGHT 1024
#endif
#ifdef RASPBERRYPI
#define WINDOW_WIDTH 800
#define WINDOW_HEIGHT 480
#endif

#ifndef WINDOW_WIDTH
#define WINDOW_WIDTH 1920
#define WINDOW_HEIGHT 1200
#endif

using ApplicationPtr = std::shared_ptr<Application>;

class Application
{
	SDLptr sdl;
	bool onRaspberry;
	bool onMacMini;
	bool isFullscreen;
	bool shouldStop;
	bool shouldRestart;

	TimerPtr timer;
	ScriptManagerPtr scripts;

	RenderListPtr renderList;
	RenderListPtr overlayRenderList;
	TexturePtr emptyTexture;

	public:
	Application();
	virtual ~Application();

	/**
	 * \param fullscreen run fullscreen
	 */
	bool init(bool fullscreen);
	void shutdown();

	void handleTextInput(const SDL_Event &event);
	void handleKeyUp(const SDL_Event &event);
	void handleKeyDown(const SDL_Event &event);
	void handleMouse(const SDL_Event &event);
	void handleTouch(const SDL_Event &event);
	void handleTimer(const SDL_Event &event);
	void render();
	void dispatchEvent(const SDL_Event& event);
	void eventLoop();

	/**
	 * Allow Lua to get/set these
	 */
	bool getOnRaspberry()
	{
#ifdef RASPBERRYPI
		return true;
#else
		return false;
#endif
	}

	bool getOnMacMini()
	{
#ifdef MACMINI
		return true;
#else
		return false;
#endif
	}

	bool getShouldStop() { return shouldStop; }
	void setShouldStop(bool val) { shouldStop = val; }
	bool getShouldRestart() { return shouldRestart; }
	void setShouldRestart(bool val) { shouldRestart = val; }
	int getTicks() { return SDL_GetTicks(); }
	RenderListPtr getRenderList() { return renderList; }
	RenderListPtr getOverlay() { return overlayRenderList; }
	void setRenderList(RenderListPtr newList) { renderList = newList; }
	void setOverlay(RenderListPtr newList) { overlayRenderList = newList; }
	const SDL_Renderer* getRenderer() { return sdl->getRenderer(); }
	void setTextInputMode(bool enable);
	void setShowCursor(bool enable);

	TexturePtr getEmptyTexture();

	void initLuaApp(ApplicationPtr app);
};

#endif // __APPLICATION_H 