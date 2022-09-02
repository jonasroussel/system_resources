import 'dart:ffi' as ffi;
import 'package:system_resources/src/dylib.dart';

typedef GetCpuLoad = double Function();
typedef GetMemoryUsage = double Function();

class SystemResources {
  static ffi.DynamicLibrary? _libsysres;

  static Future<void> init() async {
    _libsysres = await loadLibsysres;
  }

  /// Get system cpu load average
  static double cpuLoadAvg() {
    if (_libsysres == null) {
      throw Exception(
        'SystemResources are not initialized, call init() before using this method.',
      );
    }

    final fn = _libsysres!
        .lookup<ffi.NativeFunction<ffi.Float Function()>>('get_cpu_load')
        .asFunction<GetCpuLoad>();

    return fn();
  }

  /// Get system memory currently used
  static double memUsage() {
    if (_libsysres == null) {
      throw Exception(
        'SystemResources are not initialized, call init() before using this method.',
      );
    }

    final fn = _libsysres!
        .lookup<ffi.NativeFunction<ffi.Float Function()>>('get_memory_usage')
        .asFunction<GetMemoryUsage>();

    return fn();
  }
}
