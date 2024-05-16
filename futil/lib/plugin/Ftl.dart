import 'package:flutter/foundation.dart';
import 'package:futil_platform_interface/futil_platform_interface.dart';

class Ftl {
  @visibleForTesting
  static FtlInterface get platform => FtlInterface.instance;

  /// Android SDK version
  /// Other platforms will return -1
  Future<int> sdkInt() => platform.sdkInt();

  /// Returns true if the platform is HarmonyOS
  Future<bool> isHarmonyOs() => platform.isHarmonyOs();

  /// Returns a tuple of os and version
  /// e.g. ('android', '11')
  /// e.g. ('ios', '14.5')
  Future<(String, String)> osVersion() async {
    final r = await platform.osVersion();
    return (r.os, r.version);
  }

  /// iOS: vendorIdentifier
  ///    In extreme cases, it may be empty. See [https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor]
  ///    May be changed when the user deletes all apps from the vendor.
  ///
  /// Android: an uuid saved in shared_preferences generated when this method is called for the first time.
  ///    Changing when the user clears the app data or uninstalls the app.
  Future<String> deviceId() => platform.deviceId();
}
