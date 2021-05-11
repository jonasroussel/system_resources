import 'package:system_resources/system_resources.dart';

void main() {
  print('CPU Load Average : ${SystemResources.cpuLoadAvg()}');
  print('Memory Usage     : ${SystemResources.memUsage()}');
}
