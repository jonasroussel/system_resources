#include "sysres.h"

// Linux
#if __unix__

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

static long long get_entry(const char *name, const char *buff)
{
	char *hit = strstr(buff, name);
	long long val = strtoll(hit + strlen(name), NULL, 10);
	return val;
}

float get_memory_usage()
{
	FILE *fd;
	char buff[4096] = {0};

	fd = fopen("/proc/meminfo", "r");
	rewind(fd);

	size_t len = fread(buff, 1, sizeof(buff) - 1, fd);

	if (len == 0)
	{
		return 0.0f;
	}

	long long total_memory = get_entry("MemTotal:", buff);
	long long free_memory = get_entry("MemFree:", buff);
	long long buffers = get_entry("Buffers:", buff);
	long long cached = get_entry("Cached:", buff);
	long long used_memory = total_memory - free_memory - buffers - cached;

	fclose(fd);

	return (float)used_memory / (float)total_memory;
}

#endif

// MacOS
#if __MACH__

#include <mach/vm_statistics.h>
#include <mach/mach_types.h>
#include <mach/mach_init.h>
#include <mach/mach_host.h>

float get_memory_usage()
{
	vm_size_t page_size;
	mach_port_t mach_port;
	mach_msg_type_number_t count;
	vm_statistics64_data_t vm_stats;

	mach_port = mach_host_self();
	count = sizeof(vm_stats) / sizeof(natural_t);

	long long used_memory = 0;
	long long total_memory = 0;

	if (KERN_SUCCESS == host_page_size(mach_port, &page_size) && KERN_SUCCESS == host_statistics64(mach_port, HOST_VM_INFO, (host_info64_t)&vm_stats, &count))
	{
		long long free_memory = (int64_t)vm_stats.free_count * (int64_t)page_size;
		used_memory = ((int64_t)vm_stats.active_count + (int64_t)vm_stats.inactive_count + (int64_t)vm_stats.wire_count) * (int64_t)page_size;
		total_memory = free_memory + used_memory;
	}

	if (used_memory == 0 || total_memory == 0)
	{
		return 0;
	}

	return (float)used_memory / (float)total_memory;
}

#endif

// Windows
#if _WIN64

// TODO

#endif
