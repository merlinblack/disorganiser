#include <non_blocking_process_read.h>
#include <vector>
#include <string>
#include <sstream>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

using StringVector = std::vector<std::string>;

bool NonBlockingProcessRead::open()
{
	std::vector<char *> cargs;

	cargs.reserve(args.size()+1);

	cargs.push_back(program.data());

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

#ifdef __APPLE__
int NonBlockingProcessRead::pipe2(int fds[2], int flags)
{
    int ret;
	int prev_flags;

    ret = pipe(fds);
    if (ret < 0)
    {
        return ret;
    }

	prev_flags = fcntl(fds[0], F_GETFL, 0);
    ret = fcntl(fds[0], F_SETFL, prev_flags | flags);
    if (ret < 0)
    {
        return ret;
    }

	prev_flags = fcntl(fds[0], F_GETFL, 0);
    ret = fcntl(fds[1], F_SETFL, prev_flags | flags);
    if (ret < 0)
    {
        return ret;
    }

    return 0;
}
#endif
