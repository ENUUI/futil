import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  swiftOut: 'ios/Classes/messages.g.swift',
  swiftOptions: SwiftOptions(),
))
@HostApi()
abstract class FutilIosApi {
  @async
  @SwiftFunction('sdkInt()')
  int sdkInt();

  @async
  @SwiftFunction('isHarmonyOs()')
  bool isHarmonyOs();

  @async
  @SwiftFunction('osVersion()')
  Map<String, String>? osVersion();

  @async
  @SwiftFunction('deviceId()')
  String deviceId();
}
