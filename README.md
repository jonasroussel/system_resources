# System Resources
[![pub package](https://img.shields.io/pub/v/system_resources.svg)](https://pub.dev/packages/system_resources)

Provides easy access to system resources (CPU load, memory usage).

## Usage

```dart
import 'package:system_resources/system_resources.dart';

void main() {
  print('CPU Load Average : ${SystemResources.cpuLoadAvg()}');
  print('Memory Usage     : ${SystemResources.memUsage()}');
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/jonasroussel/system_resources/issues).
