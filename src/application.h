#ifndef __APPLICATION_H 
#define __APPLICATION_H 

#include "sdl.h"
#include "font.h"
#include "texture.h"
#include "timer.h"
#include "renderlist.h"
#include "rectangle.h"
#include "script_manager.h"
#include "telnet_console.h"
#include <memory>

class Application;

using ApplicationPtr = std::shared_ptr<Application>;

class Application
{
	SDLptr sdl;
	bool onRaspberry;
	bool onMacMini;
	bool isFullscreen;
	bool shouldStop;
	bool shouldRestart;
	bool isPictureFrame;
	bool hasTouchScreen;

	bool sdlInitialised;

	int width;
	int height;

	TimerPtr timer;
	ScriptManagerPtr scripts;
	TelnetConsolePtr telnet;

	RenderListPtr renderList;
	RenderListPtr overlayRenderList;
	TexturePtr emptyTexture;

	public:
	Application();
	virtual ~Application();

	/**
	 * \param fullscreen run fullscreen
	 */
	bool initSDL(bool fullscreen);
	void initLuaAppPtr(ApplicationPtr app);
	void loadConfig(std::string configPath);
	void initSystem();
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
	bool getOnRaspberry() { return onRaspberry; }
	void setOnRaspberry(bool val) { onRaspberry = val; }
	bool getOnMacMini() { return onMacMini; }
	void setOnMacMini(bool val) { onMacMini = val; }
	bool getIsPictureFrame() { return isPictureFrame; }
	void setIsPictureFrame(bool val) { isPictureFrame = val; }
	bool getHasTouchScreen() { return hasTouchScreen; }
	void setHasTouchScreen(bool val) { hasTouchScreen = val; }
	int getWidth() { return width; }
	void setWidth(int val) { if(!sdlInitialised) { width = val; } }
	int getHeight() { return height; }
	void setHeight(int val) { if(!sdlInitialised) { height = val; } }
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
};

#endif // __APPLICATION_H 