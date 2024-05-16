import 'package:flutter/services.dart';
import 'package:futil_platform_interface/futil_platform_interface.dart';

class FutilAndroid extends FtlInterface {
  static const MethodChannel _channel = MethodChannel('github.enuui/futil');

  static void registerWith() {
    FtlInterface.instance = FutilAndroid();
  }

  @override
  Future<int> sdkInt() async {
    final r = await _channel.invokeMethod<int>('skd_int');
    if (r == null) {
      throw PlatformException(
        code: 'UNKNOWN',
        message: 'Unable to get sdk int',
      );
    }
    return r;
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
