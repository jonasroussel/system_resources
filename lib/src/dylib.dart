import 'dart:io';
import 'dart:cli';
import 'dart:ffi';
import 'dart:isolate' show Isolate;

const Set<String> _supported = {
  'linux-x86_64',
  'linux-i686',
  'linux-aarch64',
  'darwin-x86_64',
};

String _filename() {
  final uname = Process.runSync('uname', ['-sm'])
      .stdout
      .toString()
      .trim()
      .toLowerCase()
      .split(' ');

  final os = uname[0];
  var arch = uname[1];
  final ext = os == 'darwin' ? 'dylib' : 'so';

  if (arch == 'i386') arch = 'i686';

  final target = os + '-' + arch;
  if (!_supported.contains(target)) {
    throw Exception('Unsupported platform: $target!');
  }

  return 'libsysres-$target.$ext';
}

DynamicLibrary libsysres = () {
  String objectFile;

  if (Platform.script.path.endsWith('.snapshot')) {
    objectFile = File.fromUri(Platform.script).parent.path + '/' + _filename();
  } else {
    final rootLibrary = 'package:system_resources/system_resources.dart';
    final build = waitFor(Isolate.resolvePackageUri(Uri.parse(rootLibrary)))
        ?.resolve('build/');

    if (build == null) {
      throw Exception('Library could not be loaded!');
    }

    objectFile = build.resolve(_filename()).toFilePath();
  }

  return DynamicLibrary.open(objectFile);
}();
