#ifndef __NON_BLOCKING_PROCESS_READ_H
#define __NON_BLOCKING_PROCESS_READ_H
#include <vector>
#include <string>
#include <memory>
#include <sys/wait.h>

using StringVector = std::vector<std::string>;

class NonBlockingProcess
{
	std::string program;
	StringVector args;
	int fd_read;
	int fd_write;
	pid_t child_pid;

	public:
	NonBlockingProcess() : fd_read(-1), fd_write(-1), child_pid(-1) {}
	~NonBlockingProcess() { close(); }

	inline void setProgram(const std::string& prog) { program = prog; }
	inline void addArgument(const std::string& newArg) { args.push_back(newArg); };
	inline void clearArgs() { args.clear(); }
	/** \return true on error */
	bool open(bool openWriteChannel = false);
	/** \return true if there is more to be read, false for error or finished */
	bool read(std::string& buffer);
	/** \return true on error */
	bool write(std::string& buffer);	
	void close();
	void closeWriteChannel();
#ifdef __APPLE__
    int pipe2( int fds[2], int flags);
#endif
};

using NonBlockingProcessPtr = std::shared_ptr<NonBlockingProcess>;

#endif // __NON_BLOCKING_PROCESS_READ_HW
