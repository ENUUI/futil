import 'package:flutter/services.dart';
import 'package:futil_platform_interface/futil_platform_interface.dart';

import 'src/messages.g.dart';

class FutilAndroid extends FtlInterface {
  final FutilAndroidApi _hostApi = FutilAndroidApi();

  static void registerWith() {
    FtlInterface.instance = FutilAndroid();
  }

  @override
  Future<int> sdkInt() {
    return _hostApi.sdkInt();
  }

  @override
  Future<bool> isHarmonyOs() {
    return _hostApi.isHarmonyOs();
  }

  @override
  Future<OsVersion> osVersion() async {
    final r = await _hostApi.osVersion();
    if (r == null) {
      throw PlatformException(
          code: 'null-error',
          message:
              'Host platform returned null value for non-null return value.');
    }

    final os = r['os'];
    final version = r['version'];

    if (os == null || version == null) {
      throw PlatformException(
          code: 'null-error',
          message:
              'Host platform returned null value for non-null return value.');
    }

    return OsVersion(os: os, version: version);
  }

  @override
  Future<String> deviceId() {
    return _hostApi.deviceId();
  }
}
