import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'backend.dart';

/// `struct vm_statistics64` (`<mach/vm_statistics.h>`).
final class _VmStatistics64 extends Struct {
  @Uint32()
  external int freeCount;
  @Uint32()
  external int activeCount;
  @Uint32()
  external int inactiveCount;
  @Uint32()
  external int wireCount;
  @Uint64()
  external int zeroFillCount;
  @Uint64()
  external int reactivations;
  @Uint64()
  external int pageins;
  @Uint64()
  external int pageouts;
  @Uint64()
  external int faults;
  @Uint64()
  external int cowFaults;
  @Uint64()
  external int lookups;
  @Uint64()
  external int hits;
  @Uint64()
  external int purges;
  @Uint32()
  external int purgeableCount;
  @Uint32()
  external int speculativeCount;
  @Uint64()
  external int decompressions;
  @Uint64()
  external int compressions;
  @Uint64()
  external int swapins;
  @Uint64()
  external int swapouts;
  @Uint32()
  external int compressorPageCount;
  @Uint32()
  external int throttledCount;
  @Uint32()
  external int externalPageCount;
  @Uint32()
  external int internalPageCount;
  @Uint64()
  external int totalUncompressedPagesInCompressor;
}

const _kernSuccess = 0;
const _hostVmInfo64 = 4;

final _libSystem = DynamicLibrary.process();

final _getloadavg = _libSystem.lookupFunction<
    Int Function(Pointer<Double>, Int),
    int Function(Pointer<Double>, int)>('getloadavg');

final _sysctlbyname = _libSystem.lookupFunction<
    Int Function(
        Pointer<Utf8>, Pointer<Void>, Pointer<Size>, Pointer<Void>, Size),
    int Function(Pointer<Utf8>, Pointer<Void>, Pointer<Size>, Pointer<Void>,
        int)>('sysctlbyname');

final _machHostSelf = _libSystem
    .lookupFunction<Uint32 Function(), int Function()>('mach_host_self');

final _hostPageSize = _libSystem.lookupFunction<
    Int Function(Uint32, Pointer<UintPtr>),
    int Function(int, Pointer<UintPtr>)>('host_page_size');

final _hostStatistics64 = _libSystem.lookupFunction<
    Int Function(Uint32, Int, Pointer<_VmStatistics64>, Pointer<Uint32>),
    int Function(int, int, Pointer<_VmStatistics64>,
        Pointer<Uint32>)>('host_statistics64');

final class DarwinBackend extends Backend {
  final int _host = _machHostSelf();
  final Pointer<Double> _load = calloc<Double>();
  final Pointer<Uint32> _count = calloc<Uint32>();
  final Pointer<_VmStatistics64> _stats = calloc<_VmStatistics64>();
  late final int _pageSize = _readPageSize();
  late final int _totalMemory = _readTotalMemory();

  @override
  void init() {
    _pageSize;
    _totalMemory;
  }

  @override
  double cpuLoadAvg() {
    if (_getloadavg(_load, 1) != 1) {
      throw const OSError('getloadavg() failed');
    }
    return _load.value / Platform.numberOfProcessors;
  }

  /// Same "Memory Used" as Activity Monitor: app memory + wired + compressed.
  @override
  double memUsage() {
    _count.value = sizeOf<_VmStatistics64>() ~/ sizeOf<Int32>();
    if (_hostStatistics64(_host, _hostVmInfo64, _stats, _count) !=
        _kernSuccess) {
      throw const OSError('host_statistics64() failed');
    }
    final stats = _stats.ref;
    final usedPages = stats.internalPageCount -
        stats.purgeableCount +
        stats.wireCount +
        stats.compressorPageCount;
    return (usedPages * _pageSize / _totalMemory).clamp(0.0, 1.0);
  }

  int _readPageSize() {
    final size = calloc<UintPtr>();
    try {
      if (_hostPageSize(_host, size) != _kernSuccess) {
        throw const OSError('host_page_size() failed');
      }
      return size.value;
    } finally {
      calloc.free(size);
    }
  }

  static int _readTotalMemory() {
    final name = 'hw.memsize'.toNativeUtf8();
    final value = calloc<Uint64>();
    final length = calloc<Size>()..value = sizeOf<Uint64>();
    try {
      if (_sysctlbyname(name, value.cast(), length, nullptr, 0) != 0) {
        throw const OSError('sysctlbyname("hw.memsize") failed');
      }
      return value.value;
    } finally {
      calloc
        ..free(name)
        ..free(value)
        ..free(length);
    }
  }
}
