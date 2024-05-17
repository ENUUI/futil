import 'package:freezed_annotation/freezed_annotation.dart';

part 'gen/os_version.freezed.dart';

part 'gen/os_version.g.dart';

@freezed
class OsVersion with _$OsVersion {
  factory OsVersion({
    required String version,
    required String os,
  }) = _OsVersion;

  factory OsVersion.fromJson(Map<String, dynamic> json) =>
      _$OsVersionFromJson(json);
}
