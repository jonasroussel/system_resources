#include "sysres.h"

// Linux
#if __unix__

#include <stdlib.h>
#include <sys/sysinfo.h>

float get_cpu_load()
{
	double load[1] = {0};

	getloadavg(load, 1);

	return load[0] / get_nprocs();
}

#endif

#if __MACH__

#include <stdlib.h>
#include <sys/types.h>
#include <sys/sysctl.h>

float get_cpu_load()
{
	double load[1] = {0};
	int thread_count;
	size_t len = sizeof(thread_count);

	getloadavg(load, 1);
	sysctlbyname("machdep.cpu.thread_count", &thread_count, &len, NULL, 0);

	return load[0] / thread_count;
}

#endif

// Windows
#if _WIN64

// TODO

#endif
