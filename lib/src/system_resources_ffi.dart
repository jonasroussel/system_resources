import 'dart:io' show Platform;

import 'backend.dart';
import 'darwin.dart';
import 'linux.dart';
import 'windows.dart';

Backend? _createBackend() {
  if (Platform.isLinux || Platform.isAndroid) return LinuxBackend();
  if (Platform.isMacOS || Platform.isIOS) return DarwinBackend();
  if (Platform.isWindows) return WindowsBackend();
  return null;
}

final Backend? _backend = _createBackend();

Backend get _requireBackend =>
    _backend ??
    (throw UnsupportedError(
      'system_resources does not support ${Platform.operatingSystem}.',
    ));

/// Provides easy access to system resources (CPU load, memory usage).
abstract final class SystemResources {
  /// Whether the current platform is supported.
  static bool get isSupported => _backend != null;

  /// Optional: prepares the platform backend ahead of the first call.
  ///
  /// On Windows, this also takes the first CPU sample, so the next
  /// [cpuLoadAvg] call measures the CPU usage since [init].
  static Future<void> init() async => _requireBackend.init();

  /// System CPU load, normalized by the number of logical processors.
  ///
  /// `1.0` means all cores are busy. It can be greater than `1.0` when the
  /// system is overloaded (except on Windows).
  ///
  /// - Linux, Android, macOS, iOS: 1-minute load average / CPU count.
  /// - Windows: CPU usage since the previous call (or since [init]).
  static double cpuLoadAvg() => _requireBackend.cpuLoadAvg();

  /// Fraction of the physical memory currently used, between `0.0` and `1.0`.
  static double memUsage() => _requireBackend.memUsage();
}
