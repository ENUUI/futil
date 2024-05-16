import 'dart:async';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:tuple/tuple.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import 'error.dart';

class PickResult {
  final String name;
  final int width;
  final int height;

  PickResult({required this.name, required this.width, required this.height});
}

class PickImage {
  PickImage({required this.cacheDir, this.onPermissionRequest});

  final String cacheDir; // 缓存目录
  final Future<void> Function()? onPermissionRequest; // 请求权限回调

  Future<PickResult> pick() async {
    await onPermissionRequest?.call();

    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (xFile == null) {
      throw CommonCancelException(message: '未选择图片');
    }

    final path = xFile.path;
    if (path.isEmpty) {
      throw CommonException(message: '图片读取失败');
    }

    final name = _nameFromPath(path);

    try {
      final pictureDir = Directory(cacheDir);
      if (!await pictureDir.exists()) {
        await pictureDir.create(recursive: true);
      }
      final destinationPath = p.join(cacheDir, name);
      await xFile.saveTo(destinationPath);
      final size = await _locImageInfo(path);
      return PickResult(name: name, width: size.item1, height: size.item2);
    } catch (e) {
      throw CommonException(message: '图片读取失败');
    }
  }

  Future<Tuple2<int, int>> _locImageInfo(String path) async {
    final completer = Completer<Tuple2<int, int>>();
    final fileImage = FileImage(File(path));

    void evict() {
      fileImage.evict().then((value) {}).catchError((_) {});
    }

    fileImage.resolve(ImageConfiguration.empty).addListener(ImageStreamListener(
          (info, _) {
            if (completer.isCompleted) return;
            completer.complete(Tuple2<int, int>(
              info.image.width,
              info.image.height,
            ));
            evict();
          },
          onError: (exc, tree) {
            if (completer.isCompleted) return;
            completer.completeError(exc, tree);
            evict();
          },
        ));

    Future.delayed(const Duration(seconds: 5)).then((value) {
      if (completer.isCompleted) return;
      completer.completeError(CommonException(message: "读取图片超时"));
      evict();
    });
    return completer.future;
  }

  String _nameFromPath(String path) {
    final now = DateTime.now();
    return '${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}-${path.split('/').last}';
  }
}
