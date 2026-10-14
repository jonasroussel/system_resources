## 2.0.0

- Rewrite in pure Dart with `dart:ffi` calls to the OS APIs: no bundled
  native library anymore. Fixes "Library could not be loaded!" errors with
  `dart compile exe`, Docker and some Linux servers (#1, #5, #6).
- Add Windows support (#3).
- Add Android and iOS support, and every CPU architecture supported by Dart (#4).
- `init()` is now optional.
- Add `SystemResources.isSupported`. On web, the package compiles but is not supported.
- Linux: `memUsage()` uses `MemAvailable` (falls back to `MemFree + Buffers + Cached`).
- macOS: `memUsage()` now matches Activity Monitor "Memory Used" (it was always close to 100%).
- Require Dart 3.5.

## 1.6.0

- https://github.com/jonasroussel/system_resources/pull/2

## 1.5.0

- Adding `darwin-arm64` (Mac M1) to support list

## 1.4.2

- Support for `linux-armv7l`
- Better README.md

## 1.4.1

- Fixing linux negative memory

## 1.4.0

- Improve linux memory usage (substract buffers & cached)

## 1.3.0

- Improve linux memory usage
- Adding `linux-aarch64` to support list

## 1.2.0

- Improve linux cpu load average
- Better cpu arch detection

## 1.1.0

- Improve macos cpu load average

## 1.0.0

- First version with every based features
