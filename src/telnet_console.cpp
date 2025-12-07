#include "telnet_console.h"
#include <LuaRef.h>
#include <SDL2/SDL.h>

#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <string.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>
#include <algorithm>

using ManualBind::LuaRef;

static const char LuaRegisteryGUID = 0;

TelnetConsole::TelnetConsole(lua_State* L) : port(8023), L(L)
{
  initListenPort();

  if (!hasFailed)
    initLua();

  SDL_Log("Telnet enabled\n");
}

void TelnetConsole::initListenPort()
{
  hasFailed = false;

  struct sockaddr_in serv_addr;

  listenSocket = socket(AF_INET, SOCK_STREAM | SOCK_NONBLOCK, 0);

  if (listenSocket < 0) {
    intialisationError();
    return;
  }

  memset(&serv_addr, 0, sizeof(sockaddr_in));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = INADDR_ANY;
  serv_addr.sin_port = htons(port);

  if (bind(listenSocket, (struct sockaddr*)&serv_addr, sizeof(sockaddr_in)) <
      0) {
    intialisationError();
    return;
  }

  if (listen(listenSocket, 5) < 0) {
    intialisationError();
    return;
  }
}

void TelnetConsole::initLua()
{
  lua_pushlightuserdata(L, (void*)&LuaRegisteryGUID);
  lua_pushlightuserdata(L, this);
  lua_settable(L, LUA_REGISTRYINDEX);
  lua_pushcfunction(L, receiveOutput);
  lua_setglobal(L, "telnetOutput");
}

/** \note: static member to allow binding to Lua */
int TelnetConsole::receiveOutput(lua_State* L)
{
  lua_pushlightuserdata(L, (void*)&LuaRegisteryGUID);
  lua_gettable(L, LUA_REGISTRYINDEX);
  TelnetConsole* self = static_cast<TelnetConsole*>(lua_touserdata(L, -1));
  lua_pop(L, 1);

  if (self->clientSockets.empty()) {
    return 0;  // No point if no-one is connected.
  }

  std::string line(lua_tostring(L, 1));

  self->outputLines.emplace_back(line);

  return 0;
}

void TelnetConsole::process()
{
  if (!hasFailed) {
    checkForNewClients();
    processClients();
  }
}

void TelnetConsole::checkForNewClients()
{
  struct sockaddr_in clientAddress;
  socklen_t clientAddressLen = sizeof(sockaddr_in);

  int newClient = accept4(listenSocket, (struct sockaddr*)&clientAddress,
                          &clientAddressLen, SOCK_NONBLOCK);

  if (newClient == -1) {
    if (errno == EAGAIN || errno == EWOULDBLOCK)
      return;

    intialisationError();
    return;
  }

  std::string ipaddr(inet_ntoa(clientAddress.sin_addr));

  if (!allowedIP(ipaddr)) {
    close(newClient);

    return;
  }

  clientSockets.push_back(newClient);

  writeMessage(newClient, "Connected to console.\n\n> ");

  return;
}

bool TelnetConsole::allowedIP(std::string ipAddress)
{
  if (ipAddress == "127.0.0.1")
    return true;

  bool allowed = false;

  LuaRef allowedIPs = LuaRef::getGlobal(L, "telnetAllowedIPs");

  if (allowedIPs.isTable()) {
    allowedIPs.push();
    lua_pushnil(L);
    while (lua_next(L, -2)) {
      if (ipAddress == lua_tostring(L, -1)) {
        allowed = true;
        break;
      }
      lua_pop(L, 1);
    }
  }

  lua_settop(L, 0);

  return allowed;
}

void TelnetConsole::processClients()
{
  char buffer[1024];

  std::vector<int> deadConnections;

  if (!outputLines.empty()) {
    outputLines.push_back("> ");
  }

  for (auto clientSocket : clientSockets) {
    int n = 0;
    for (auto line : outputLines) {
      n = writeMessage(clientSocket, line.c_str());
      if (n == -1)
        break;
    }
    if (n == -1) {
      deadConnections.push_back(clientSocket);
      continue;
    }

    memset(buffer, 0, sizeof(buffer));
    n = recv(clientSocket, buffer, sizeof(buffer), MSG_NOSIGNAL);

    if (n == -1) {
      if (errno == EAGAIN || errno == EWOULDBLOCK)
        continue;

      deadConnections.push_back(clientSocket);
      continue;
    }

    if (n == 0)
      continue;

    LuaRef run = LuaRef::getGlobal(L, "console")["run"];

    run["insertLine"](run, (const char*)(buffer));
  }

  outputLines.clear();

  // Reap the dead
  for (auto dead : deadConnections) {
    std::erase(clientSockets, dead);
    close(dead);
  }
}

ssize_t TelnetConsole::writeMessage(int fd, const char* message)
{
  return send(fd, message, strlen(message), MSG_NOSIGNAL);
}

void TelnetConsole::shutdown()
{
  for (auto clientSocket : clientSockets) {
    writeMessage(clientSocket, "Güle güle!\n");
    close(clientSocket);
  }
  clientSockets.clear();

  if (listenSocket > 0)
    close(listenSocket);

  listenSocket = 0;
}

void TelnetConsole::intialisationError()
{
  hasFailed = true;
  lastError = strerror(errno);
  SDL_Log("Error initialising telnet listening port: %s\n", lastError);
}