import 'dart:ffi' as ffi;
import 'package:system_resources/src/dylib.dart';

typedef GetCpuLoad = double Function();
typedef GetMemoryUsage = double Function();

class SystemResources {
  /// Get system cpu load average
  static double cpuLoadAvg() {
    final fn = libsysres
        .lookup<ffi.NativeFunction<ffi.Float Function()>>('get_cpu_load')
        .asFunction<GetCpuLoad>();

    return fn();
  }

  /// Get system memory currently used
  static double memUsage() {
    final fn = libsysres
        .lookup<ffi.NativeFunction<ffi.Float Function()>>('get_memory_usage')
        .asFunction<GetMemoryUsage>();

    return fn();
  }
}
