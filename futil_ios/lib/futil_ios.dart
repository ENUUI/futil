import 'package:flutter/services.dart';
import 'package:futil_platform_interface/futil_platform_interface.dart';

class FutilIos extends FtlInterface {
  static const MethodChannel _channel = MethodChannel('github.enuui/futil');

  static void registerWith() {
    FtlInterface.instance = FutilIos();
  }

  @override
  Future<int> sdkInt() {
    return Future.value(-1);
  }

  @override
  Future<bool> isHarmonyOs() {
    return Future.value(false);
  }

  @override
  Future<OsVersion> osVersion() async {
    final result = await _channel.invokeMapMethod('os_version');
    if (result == null) {
      throw PlatformException(
        code: 'UNKNOWN',
        message: 'Unable to get os version',
      );
    }
    return OsVersion.fromJson(result.cast());
  }

  @override
  Future<String> deviceId() async {
    return await _channel.invokeMethod('device_id');
  }
}
