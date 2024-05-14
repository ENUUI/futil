import 'dart:io';

import 'package:path/path.dart';
import 'package:flutter/services.dart';

class AssetReader {
  AssetReader({this.asset = ''});

  final String asset;

  /// 获取资源文件的字节数据
  /// [name] 资源文件名
  /// [asset] 资源目录, 如 'assets/images'
  /// return 字节数据
  Future<ByteData> byteData(String name, {String? asset}) {
    if (name.isEmpty) {
      throw ArgumentError('name is empty');
    }

    final path = join(asset ?? this.asset, name);
    return rootBundle.load(path);
  }

  /// 将资源文件保存到指定目录
  /// [name] 资源文件名
  /// [destination] 目标目录, 如 '/path/to/file.jpg'
  /// [asset] 资源目录, 如 'assets/images'
  /// return 文件对象
  Future<File> saveTo(String name, String destination, {String? asset, bool force = false}) async {
    if (destination.isEmpty) {
      throw ArgumentError('destination is empty');
    }

    if (!destination.contains('.')) {
      throw ArgumentError('destination must contain extension');
    }

    if (!force) {
      final file = File(destination);
      if (await file.exists()) {
        return file;
      }
    }

    if (name.isEmpty) {
      throw ArgumentError('name is empty');
    }

    final data = await byteData(name, asset: asset);

    final buffer = data.buffer.asUint8List();
    final file = File(destination);
    await file.writeAsBytes(buffer, flush: false);

    return file;
  }
}
