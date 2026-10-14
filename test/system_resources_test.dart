import 'package:system_resources/src/linux.dart' show parseMemInfoUsage;
import 'package:system_resources/system_resources.dart';
import 'package:test/test.dart';

void main() {
  group('SystemResources', () {
    test('is supported on this platform', () {
      expect(SystemResources.isSupported, isTrue);
    });

    test('works without init()', () {
      expect(SystemResources.cpuLoadAvg(), greaterThanOrEqualTo(0.0));
      expect(SystemResources.memUsage(), inInclusiveRange(0.0, 1.0));
    });

    test('cpuLoadAvg is a non-negative finite value', () async {
      await SystemResources.init();
      for (var i = 0; i < 5; i++) {
        final load = SystemResources.cpuLoadAvg();
        expect(load.isFinite, isTrue);
        expect(load, greaterThanOrEqualTo(0.0));
      }
    });

    test('memUsage is a used fraction of the memory', () {
      final usage = SystemResources.memUsage();
      expect(usage, greaterThan(0.0));
      expect(usage, lessThanOrEqualTo(1.0));
    });
  });

  group('parseMemInfoUsage', () {
    test('uses MemAvailable when present', () {
      const memInfo = '''
MemTotal:       16000000 kB
MemFree:         1000000 kB
MemAvailable:    4000000 kB
Buffers:          500000 kB
Cached:          6000000 kB
SwapCached:        10000 kB
''';
      expect(parseMemInfoUsage(memInfo), closeTo(0.75, 1e-9));
    });

    test('falls back to MemFree + Buffers + Cached (old kernels)', () {
      const memInfo = '''
MemTotal:       10000 kB
MemFree:         2000 kB
Buffers:         1000 kB
Cached:          3000 kB
SwapCached:      9000 kB
''';
      expect(parseMemInfoUsage(memInfo), closeTo(0.4, 1e-9));
    });

    test('throws when MemTotal is missing', () {
      expect(
        () => parseMemInfoUsage('MemFree: 1 kB\n'),
        throwsFormatException,
      );
    });
  });
}
