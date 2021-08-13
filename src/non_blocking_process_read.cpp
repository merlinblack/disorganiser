#include <vector>
#include <string>
#include <sstream>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

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

bool NonBlockingProcessRead::open()
{
	std::vector<char *> cargs;

	cargs.reserve(args.size()+1);

	for( std::string& sp: args)
	{
		cargs.push_back(sp.data());
	}

	cargs.push_back(nullptr);

	int p[2];

	if (pipe2(p, O_NONBLOCK))
	{
		return true;
	}

	switch(fork())
	{
		case -1:
			::close(p[0]);
			::close(p[1]);
			return true;
		case 0:
			// Child - close read end of the pipe
			::close(p[0]);
			// Make stdout into writable end
			dup2(p[1], 1);
			// Run program
			execvp(cargs[0], cargs.data());
			// If we got here, something went wrong
			perror(cargs[0]);
			// child process should not continue
			exit(EXIT_FAILURE);
		default:
			// Parent - close the write end of the  pipe
			::close(p[1]);
			fd = p[0];
			return false;
	}
}

bool NonBlockingProcessRead::read(std::string& buffer)
{
	if (fd<0)
	{
		return false;
	}

	char buf[1024];
	ssize_t r;
	std::stringstream ss;
	
	do
	{
		r = ::read(fd, buf, 1024);
		if (r>0)
		{
			buf[r] = 0;
			ss << buf;
		}
	}
	while (r>0);

	buffer = ss.str();

	if (r == 0 || (r == -1 && errno != EAGAIN))
	{
		return false;
	}
	return true;
}

void NonBlockingProcessRead::close()
{
	if (fd >= 0)
	{
		::close(fd);
		fd = -1;
	}
}