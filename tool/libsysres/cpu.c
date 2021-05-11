#include "sysres.h"

// Linux & MacOS
#if __unix__ || __MACH__

#include <stdlib.h>

float get_cpu_load()
{
	double load[1] = {0};
	getloadavg(load, 1);
	return load[0];
}

#endif

// Windows
#if _WIN32

// TODO

#endif
