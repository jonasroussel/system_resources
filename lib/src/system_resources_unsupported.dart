/// Provides easy access to system resources (CPU load, memory usage).
///
/// This platform (web) has no access to system resources: [isSupported] is
/// `false` and every other member throws an [UnsupportedError].
abstract final class SystemResources {
  /// Whether the current platform is supported.
  static bool get isSupported => false;

  /// Throws an [UnsupportedError] on this platform.
  static Future<void> init() async => throw _unsupported();

  /// Throws an [UnsupportedError] on this platform.
  static double cpuLoadAvg() => throw _unsupported();

  /// Throws an [UnsupportedError] on this platform.
  static double memUsage() => throw _unsupported();

  static UnsupportedError _unsupported() =>
      UnsupportedError('system_resources is not supported on this platform.');
}
