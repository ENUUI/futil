import 'package:flutter/services.dart';
import 'package:futil_platform_interface/futil_platform_interface.dart';

import 'src/messages.g.dart';

class FutilIos extends FtlInterface {
  final FutilIosApi _hotsApi = FutilIosApi();

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
    final r = await _hotsApi.osVersion();

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
    return _hotsApi.deviceId();
  }
}
