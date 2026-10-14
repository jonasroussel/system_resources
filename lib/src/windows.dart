import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'backend.dart';

/// `MEMORYSTATUSEX` (`<sysinfoapi.h>`).
final class _MemoryStatusEx extends Struct {
  @Uint32()
  external int dwLength;

  @Uint32()
  external int dwMemoryLoad;

  @Uint64()
  external int ullTotalPhys;

  @Uint64()
  external int ullAvailPhys;

  @Uint64()
  external int ullTotalPageFile;

  @Uint64()
  external int ullAvailPageFile;

  @Uint64()
  external int ullTotalVirtual;

  @Uint64()
  external int ullAvailVirtual;

  @Uint64()
  external int ullAvailExtendedVirtual;
}

final _kernel32 = DynamicLibrary.open('kernel32.dll');

/// `FILETIME` is read as a little-endian `Uint64` (100 ns ticks).
final _getSystemTimes = _kernel32.lookupFunction<
    Int32 Function(Pointer<Uint64>, Pointer<Uint64>, Pointer<Uint64>),
    int Function(Pointer<Uint64>, Pointer<Uint64>, Pointer<Uint64>)>(
  'GetSystemTimes',
);

final _globalMemoryStatusEx = _kernel32.lookupFunction<
    Int32 Function(Pointer<_MemoryStatusEx>),
    int Function(Pointer<_MemoryStatusEx>)>('GlobalMemoryStatusEx');

final class WindowsBackend extends Backend {
  final Pointer<Uint64> _times = calloc<Uint64>(3);
  final Pointer<_MemoryStatusEx> _memStatus = calloc<_MemoryStatusEx>()
    ..ref.dwLength = sizeOf<_MemoryStatusEx>();

  int _lastIdle = 0;
  int _lastTotal = 0;
  double _lastLoad = 0;

  @override
  void init() => cpuLoadAvg();

  /// CPU usage since the previous call, or since boot on the first call.
  @override
  double cpuLoadAvg() {
    if (_getSystemTimes(_times, _times + 1, _times + 2) == 0) {
      throw const OSError('GetSystemTimes() failed');
    }
    final idle = _times[0];
    // Kernel time includes idle time.
    final total = _times[1] + _times[2];

    final totalDelta = total - _lastTotal;
    if (totalDelta > 0) {
      _lastLoad = (1 - (idle - _lastIdle) / totalDelta).clamp(0.0, 1.0);
      _lastIdle = idle;
      _lastTotal = total;
    }
    return _lastLoad;
  }

  @override
  double memUsage() {
    if (_globalMemoryStatusEx(_memStatus) == 0) {
      throw const OSError('GlobalMemoryStatusEx() failed');
    }
    final status = _memStatus.ref;
    if (status.ullTotalPhys == 0) return 0;
    return (status.ullTotalPhys - status.ullAvailPhys) / status.ullTotalPhys;
  }
}
