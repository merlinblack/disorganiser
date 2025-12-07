#ifndef TELNET_CONSOLE_H
#define TELNET_CONSOLE_H

#include <lua.hpp>
#include <memory>
#include <string>
#include <vector>

class TelnetConsole {
  int port;
  std::vector<int> clientSockets;
  int listenSocket;
  lua_State* L;
  std::string lastError;
  bool hasFailed;
  std::vector<std::string> outputLines;

 public:
  TelnetConsole(lua_State* L);
  ~TelnetConsole() { this->shutdown(); };
  bool failed() { return hasFailed; }
  std::string getLastError() { return lastError; }

  void process();
  void shutdown();

 private:
  void initListenPort();
  void initLua();
  void checkForNewClients();
  void processClients();
  void intialisationError();
  ssize_t writeMessage(int fd, const char* message);
  bool allowedIP(std::string ipAddress);

  static int receiveOutput(lua_State* L);
};

using TelnetConsolePtr = std::shared_ptr<TelnetConsole>;

#endif  // TELNET_CONSOLE_H