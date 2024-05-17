library futil_platform_interface;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'msg/os_version.dart';
export 'msg/os_version.dart';

const MethodChannel _channel = MethodChannel('plugins.github.enuui/futil');

abstract class FtlInterface extends PlatformInterface {
  FtlInterface() : super(token: _token);

  static final Object _token = Object();

  static FtlInterface _instance = MethodChannelFtl();

  static FtlInterface get instance => _instance;

  static set instance(FtlInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Android SDK version
  /// Other platforms will return -1
  Future<int> sdkInt() {
    throw UnimplementedError('sdkInt() has not been implemented.');
  }

  /// Android SDK
  /// Other platforms will always return false
  Future<bool> isHarmonyOs() {
    throw UnimplementedError('isHarmonyOs() has not been implemented.');
  }

  Future<OsVersion> osVersion() {
    throw UnimplementedError('osVersion() has not been implemented.');
  }

  /// iOS: vendorIdentifier
  ///    In extreme cases, it may be empty. See [https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor]
  ///    May be changed when the user deletes all apps from the vendor.
  ///
  /// Android: an uuid saved in shared_preferences generated when this method is called for the first time.
  ///    Changing when the user clears the app data or uninstalls the app.
  Future<String> deviceId() {
    throw UnimplementedError('deviceId() has not been implemented.');
  }
}

class MethodChannelFtl extends FtlInterface {
  @visibleForTesting
  MethodChannel get channel => _channel;

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
  Future<bool> isHarmonyOs() async {
    final r = await _channel.invokeMethod<bool>('is_harmony_os');
    if (r == null) {
      throw PlatformException(
        code: 'UNKNOWN',
        message: 'Unable to get is harmony os',
      );
    }
    return r;
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
