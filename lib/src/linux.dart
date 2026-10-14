import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'backend.dart';

/// Leading fields of `struct sysinfo` (see `sysinfo(2)`).
final class _SysInfo extends Struct {
  @Long()
  external int uptime;

  @Array(3)
  external Array<UnsignedLong> loads;
}

/// `loads` are fixed-point numbers scaled by `1 << SI_LOAD_SHIFT`.
const _loadScale = 1 << 16;

/// Large enough for the whole `struct sysinfo` on every ABI (64 or 112 bytes).
const _sysInfoSize = 128;

final _sysinfo = DynamicLibrary.process().lookupFunction<
    Int Function(Pointer<_SysInfo>), int Function(Pointer<_SysInfo>)>(
  'sysinfo',
);

final class LinuxBackend extends Backend {
  final Pointer<_SysInfo> _info = calloc<Uint8>(_sysInfoSize).cast();
  final File _memInfo = File('/proc/meminfo');

  @override
  double cpuLoadAvg() {
    if (_sysinfo(_info) != 0) {
      throw const OSError('sysinfo() failed');
    }
    return _info.ref.loads[0] / _loadScale / Platform.numberOfProcessors;
  }

  @override
  double memUsage() => parseMemInfoUsage(_memInfo.readAsStringSync());
}

/// Computes the used memory fraction from `/proc/meminfo` content.
///
/// Uses `MemAvailable` (Linux 3.14+), else `MemFree + Buffers + Cached`.
double parseMemInfoUsage(String memInfo) {
  final values = <String, int>{};
  for (final line in memInfo.split('\n')) {
    final colon = line.indexOf(':');
    if (colon <= 0) continue;
    final value = int.tryParse(
      line.substring(colon + 1).trim().split(' ').first,
    );
    if (value != null) values[line.substring(0, colon)] = value;
  }

  final total = values['MemTotal'];
  if (total == null || total == 0) {
    throw const FormatException('MemTotal is missing from /proc/meminfo');
  }
  final available = values['MemAvailable'] ??
      (values['MemFree'] ?? 0) +
          (values['Buffers'] ?? 0) +
          (values['Cached'] ?? 0);

  return ((total - available) / total).clamp(0.0, 1.0);
}
