/// Provides easy access to system resources (CPU load, memory usage).
library;

export 'src/system_resources_unsupported.dart'
    if (dart.library.ffi) 'src/system_resources_ffi.dart';
