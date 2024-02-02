#include "application.h"
#include "sdl.h"
#include "script_manager.h"
#include <memory>
#include <iostream>
#include <getopt.h>


void PrintEvent(const SDL_Event * event)
{
    if (event->type == SDL_WINDOWEVENT) {
        switch (event->window.event) {
        case SDL_WINDOWEVENT_SHOWN:
            SDL_Log("Window %d shown", event->window.windowID);
            break;
        case SDL_WINDOWEVENT_HIDDEN:
            SDL_Log("Window %d hidden", event->window.windowID);
            break;
        case SDL_WINDOWEVENT_EXPOSED:
            SDL_Log("Window %d exposed", event->window.windowID);
            break;
        case SDL_WINDOWEVENT_MOVED:
            SDL_Log("Window %d moved to %d,%d",
                    event->window.windowID, event->window.data1,
                    event->window.data2);
            break;
        case SDL_WINDOWEVENT_RESIZED:
            SDL_Log("Window %d resized to %dx%d",
                    event->window.windowID, event->window.data1,
                    event->window.data2);
            break;
        case SDL_WINDOWEVENT_SIZE_CHANGED:
            SDL_Log("Window %d size changed to %dx%d",
                    event->window.windowID, event->window.data1,
                    event->window.data2);
            break;
        case SDL_WINDOWEVENT_MINIMIZED:
            SDL_Log("Window %d minimized", event->window.windowID);
            break;
        case SDL_WINDOWEVENT_MAXIMIZED:
            SDL_Log("Window %d maximized", event->window.windowID);
            break;
        case SDL_WINDOWEVENT_RESTORED:
            SDL_Log("Window %d restored", event->window.windowID);
            break;
        case SDL_WINDOWEVENT_ENTER:
            SDL_Log("Mouse entered window %d",
                    event->window.windowID);
            break;
        case SDL_WINDOWEVENT_LEAVE:
            SDL_Log("Mouse left window %d", event->window.windowID);
            break;
        case SDL_WINDOWEVENT_FOCUS_GAINED:
            SDL_Log("Window %d gained keyboard focus",
                    event->window.windowID);
            break;
        case SDL_WINDOWEVENT_FOCUS_LOST:
            SDL_Log("Window %d lost keyboard focus",
                    event->window.windowID);
            break;
        case SDL_WINDOWEVENT_CLOSE:
            SDL_Log("Window %d closed", event->window.windowID);
            break;
#if SDL_VERSION_ATLEAST(2, 0, 5)
        case SDL_WINDOWEVENT_TAKE_FOCUS:
            SDL_Log("Window %d is offered a focus", event->window.windowID);
            break;
        case SDL_WINDOWEVENT_HIT_TEST:
            SDL_Log("Window %d has a special hit test", event->window.windowID);
            break;
#endif
        default:
            SDL_Log("Window %d got unknown event %d",
                    event->window.windowID, event->window.event);
            break;
        }
    }
}

//#define LOGLEVEL SDL_LOG_PRIORITY_VERBOSE
#define LOGLEVEL SDL_LOG_PRIORITY_INFO
void Logging(void *userdata, int category, SDL_LogPriority priority, const char* message)
{
    if (priority >= LOGLEVEL)
    {
        std::cerr << message << std::endl;
    }
}

int main(int argc, char *argv[])
{
    bool shouldQuit = false;
    bool fullscreen = false;
    std::string configPath = "";

    option longOptions[] = {
        { "fullscreen", no_argument, nullptr, 'f'},
        { "config", required_argument, nullptr, 'c'},
        {0}
    };

    while(true) {
        const int opt = getopt_long(argc, argv, "fc:", longOptions, 0 );

        if (opt == -1)
            break;

        switch (opt) {
            case 'f':
                fullscreen = true;
                break;
            case 'c':
                configPath = optarg;
                break;
            case '?':
                shouldQuit = true;
                break;
        }
    }

    bool restartWanted = false;

    if (!shouldQuit)
    {
        SDL_LogSetOutputFunction(Logging, nullptr);

        ApplicationPtr app = std::make_shared<Application>();

        app->initLuaAppPtr(app);

        app->loadConfig(configPath);

        app->initSDL(fullscreen);

        app->initSystem();

        app->eventLoop();

        app->shutdown();

        restartWanted = app->getShouldRestart();
    }

    if (restartWanted)
        return 2;

    return 0;
}