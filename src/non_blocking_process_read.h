#ifndef __NON_BLOCKING_PROCESS_READ_H
#define __NON_BLOCKING_PROCESS_READ_H
#include <vector>
#include <string>
#include <memory>
#include <sys/wait.h>

using StringVector = std::vector<std::string>;

class NonBlockingProcessRead
{
	std::string program;
	StringVector args;
	int fd;
	pid_t child_pid;

	public:
	NonBlockingProcessRead() : fd(-1) {}
	~NonBlockingProcessRead() { close(); }

	inline void setProgram(const std::string& prog) { program = prog; }
	inline void addArgument(const std::string& newArg) { args.push_back(newArg); };
	inline void clearArgs() { args.clear(); }
	/** \return true on error */
	bool open();
	/** \return true if there is more to be read, false for error or finished */
	bool read(std::string& buffer);
	void close();
#ifdef __APPLE__
    int pipe2( int fds[2], int flags);
#endif
};

using NonBlockingProcessReadPtr = std::shared_ptr<NonBlockingProcessRead>;

#endif // __NON_BLOCKING_PROCESS_READ_HW
