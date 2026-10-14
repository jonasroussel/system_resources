import 'package:system_resources/system_resources.dart';

Future<void> main() async {
  await SystemResources.init();

  print('CPU Load Average : ${(SystemResources.cpuLoadAvg() * 100).toInt()}%');
  print('Memory Usage     : ${(SystemResources.memUsage() * 100).toInt()}%');
}
