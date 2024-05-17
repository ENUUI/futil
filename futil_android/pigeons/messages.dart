import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  kotlinOut: 'android/src/main/kotlin/com/example/futil_android/Messages.kt',
  kotlinOptions: KotlinOptions(
    package: 'com.example.futil_android',
  ),
))
@HostApi()
abstract class FutilAndroidApi {
  @async
  int sdkInt();

  @async
  bool isHarmonyOs();

  @async
  Map<String, String>? osVersion();

  @async
  String deviceId();
}
