import 'dart:io';
import 'dart:ffi' as ffi;
import 'package:path/path.dart';

typedef GetCpuLoad = double Function();
typedef GetMemoryUsage = double Function();

class SystemResources {
  static ffi.DynamicLibrary? _dyLib;

  static ffi.DynamicLibrary _openDyLib() {
    String? path;

    if (Platform.isLinux) {
      path = join(
        Directory.current.path,
        'tool',
        'libsysres',
        'build',
        'libsysres.so',
      );
    } else if (Platform.isMacOS) {
      path = join(
        Directory.current.path,
        'tool',
        'libsysres',
        'build',
        'libsysres.dylib',
      );
    } else {
      throw StateError('Operating System not supported!');
    }

    return ffi.DynamicLibrary.open(path);
  }

  /// Get system cpu load average
  static double cpuLoadAvg() {
    _dyLib ??= _openDyLib();

    final fn = _dyLib!
        .lookup<ffi.NativeFunction<ffi.Float Function()>>(
          'get_cpu_load',
        )
        .asFunction<GetCpuLoad>();

    return fn();
  }

  /// Get system memory currently used
  static double memUsage() {
    _dyLib ??= _openDyLib();

    final fn = _dyLib!
        .lookup<ffi.NativeFunction<ffi.Float Function()>>(
          'get_memory_usage',
        )
        .asFunction<GetMemoryUsage>();

    return fn();
  }
}
