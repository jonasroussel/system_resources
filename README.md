# System Resources

[![pub package](https://img.shields.io/pub/v/system_resources.svg)](https://pub.dev/packages/system_resources)
[![CI](https://github.com/jonasroussel/system_resources/actions/workflows/ci.yaml/badge.svg)](https://github.com/jonasroussel/system_resources/actions/workflows/ci.yaml)

Provides easy access to system resources (CPU load, memory usage).

Pure Dart: it calls the operating system APIs directly with `dart:ffi`.
There is no bundled native library and no C compiler needed, so it works the
same with `dart run`, `dart compile exe`, Docker images and Flutter apps.

## Usage

```dart
import 'package:system_resources/system_resources.dart';

Future<void> main() async {
  await SystemResources.init(); // optional

  print('CPU Load Average : ${(SystemResources.cpuLoadAvg() * 100).toInt()}%');
  print('Memory Usage     : ${(SystemResources.memUsage() * 100).toInt()}%');
}
```

| Member                         | Description                                                    |
| ------------------------------ | -------------------------------------------------------------- |
| `SystemResources.cpuLoadAvg()` | CPU load divided by the number of logical CPUs (`1.0` = full). |
| `SystemResources.memUsage()`   | Fraction of the physical memory in use, from `0.0` to `1.0`.   |
| `SystemResources.init()`       | Optional. Prepares the platform backend ahead of time.         |
| `SystemResources.isSupported`  | `false` on web and on other unsupported platforms.             |

## Platforms

| Platform        | `cpuLoadAvg`                                  | `memUsage`                                         |
| --------------- | --------------------------------------------- | -------------------------------------------------- |
| Linux, Android  | 1-minute load average (`sysinfo`)             | `MemTotal - MemAvailable` (`/proc/meminfo`)         |
| macOS, iOS      | 1-minute load average (`getloadavg`)          | App memory + wired + compressed (Activity Monitor) |
| Windows         | CPU usage since the previous call (or `init`) | `GlobalMemoryStatusEx`                             |
| Web             | Not supported                                 | Not supported                                      |

Every CPU architecture supported by Dart works (x64, arm64, arm, riscv64, ...).

Notes:

- Windows has no load average. The first `cpuLoadAvg()` call measures the
  usage since `init()`, or since boot when `init()` was not called.
- On Linux, the load average can be greater than `1.0` when processes wait
  for the CPU.
- In a container, values are those of the host (the kernel does not apply
  cgroup limits to `/proc/meminfo` and the load average).
- On web, the package compiles, but `isSupported` is `false` and the other
  members throw an `UnsupportedError`.

## Contributing

[Issues](https://github.com/jonasroussel/system_resources/issues) |
[Pull requests](https://github.com/jonasroussel/system_resources/pulls)
