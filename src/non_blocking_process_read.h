#ifndef __NON_BLOCKING_PROCESS_READ_H
#define __NON_BLOCKING_PROCESS_READ_H
#include <vector>
#include <string>
#include <memory>

using StringVector = std::vector<std::string>;

class NonBlockingProcessRead
{
	StringVector args;
	int fd;

	public:
	NonBlockingProcessRead() : fd(-1) {}
	~NonBlockingProcessRead() { close(); }

	inline void addArgument(const std::string& newArg) { args.push_back(newArg); };
	inline void clearArgs() { args.clear(); }
	/** \return true on error */
	bool open();
	/** \return true if there is more to be read, false for error or finished */
	bool read(std::string& buffer);
	void close();
};

using NonBlockingProcessReadPtr = std::shared_ptr<NonBlockingProcessRead>;

#endif // __NON_BLOCKING_PROCESS_READ_HW
