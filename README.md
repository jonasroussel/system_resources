# System Resources
[![pub package](https://img.shields.io/pub/v/system_resources.svg)](https://pub.dev/packages/system_resources)

Provides easy access to system resources (CPU load, memory usage).

## Usage

```dart
import 'package:system_resources/system_resources.dart';

void main() {
  print('CPU Load Average : ${(SystemResources.cpuLoadAvg() * 100).toInt()}%');
  print('Memory Usage     : ${(SystemResources.memUsage() * 100).toInt()}%');
}
```

## Features

### Linux

Function   | x86_64 | i686 | aarch64 | armv7l |
-----------|--------|------|---------|--------|
cpuLoadAvg | 🟢     | 🟢   | 🟢      | 🟢     |
memUsage   | 🟢     | 🟢   | 🟢      | 🟢     |

### macOS

Function   | Intel | M1 |
-----------|-------|----|
cpuLoadAvg | 🟢    | 🟠 |
memUsage   | 🟢    | 🟠 |

### Windows

Function   | 64 bit | 32 bit | ARMv7 | ARMv8+ |
-----------|--------|--------|-------|--------|
cpuLoadAvg | 🔴     | 🔴     | 🔴    | 🔴     |
memUsage   | 🔴     | 🔴     | 🔴    | 🔴     |


🟢 : Coded, Compiled, Tested

🟠 : Coded, Not Compiled

🔴 : No Code

## Improve, compile & test

You are free to improve, compile and test `libsysres` C code for any platform not fully supported.

Github
[Issues](https://github.com/jonasroussel/system_resources/issues) | [Pull requests](https://github.com/jonasroussel/system_resources/pulls)
