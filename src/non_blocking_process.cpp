#include <non_blocking_process.h>
#include <vector>
#include <string>
#include <sstream>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

using StringVector = std::vector<std::string>;

bool NonBlockingProcess::open(bool openWriteChannel)
{
	std::vector<char *> cargs;

	cargs.reserve(args.size()+1);

	cargs.push_back(program.data());

	for( std::string& sp: args)
	{
		cargs.push_back(sp.data());
	}

	cargs.push_back(nullptr);

	int p_read[2];
	int p_write[2];

	if (pipe2(p_read, O_NONBLOCK))
	{
		return true;
	}
	
	if (openWriteChannel)
	{
		if (pipe(p_write))
		{
			return true;
		}
	}

	switch(child_pid = fork())
	{
		case -1:
			::close(p_read[0]);
			::close(p_read[1]);
			if (openWriteChannel)
			{
				::close(p_write[0]);
				::close(p_write[1]);
			}
			return true;
		case 0:
			// Child 
			// close read end of the read pipe
			::close(p_read[0]);
			// Send stdout into writable end
			dup2(p_read[1], STDOUT_FILENO);
			// Send stderr into writable end
			dup2(p_read[1], STDERR_FILENO);
			// Child does not need this fd now dup is done.
			::close(p_read[1]);

			if (openWriteChannel)
			{
				// Attach stdin into readable end
				dup2(p_write[0], STDIN_FILENO);
				// Child does not need this now that the dup is done.
				::close(p_write[0]);
				// close write end of the write pipe
				::close(p_write[1]);
			}

			// Run program
			execvp(cargs[0], cargs.data());
			// If we got here, something went wrong
			perror(cargs[0]);
			// child process should not continue
			exit(EXIT_FAILURE);
		default:
			// Parent
			// close the write end of the read pipe
			::close(p_read[1]);
			fd_read = p_read[0];
			if (openWriteChannel)
			{
				// close the read end of the write pipe
				::close(p_write[0]);
				fd_write = p_write[1];
			}
			return false;
	}
}

bool NonBlockingProcess::read(std::string& buffer)
{
	if (fd_read<0)
	{
		return false;
	}

	char buf[1024];
	ssize_t r;
	std::stringstream ss;
	
	do
	{
		r = ::read(fd_read, buf, 1024);
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

bool NonBlockingProcess::write(std::string& buffer)
{
	if (fd_write<0)
	{
		return true;
	}

	ssize_t written = ::write(fd_write, buffer.data(), buffer.size());

	if (written != buffer.size())
	{
		return true;
	}

	return false;
}

void NonBlockingProcess::close()
{
	if (fd_write >= 0)
	{
		::close(fd_write);
		fd_write = -1;
	}
	if (fd_read >= 0)
	{
		::close(fd_read);
		fd_read = -1;
	}
	if (child_pid > 0)
	{
		waitpid(child_pid, nullptr, 0);
		child_pid = -1;
	}
}

void NonBlockingProcess::closeWriteChannel()
{
	if (fd_write >= 0)
	{
		::close(fd_write);
		fd_write = -1;
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
