import 'dart:io';
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as im;

/// EditedImage 编辑后的图片
class EditedImage {
  const EditedImage({
    required this.data,
    required this.width,
    required this.height,
    required this.multiFrame,
  });

  final Uint8List data;
  final int width;
  final int height;
  final bool multiFrame;
}

/// ImageEditorOpt 图片编辑器配置
class ImageEditorOpt {
  const ImageEditorOpt({
    this.cornerColor,
    this.lineColor,
    this.maskColor,
    this.maskColorOnTouchDown,
    this.ratio = 1.0,
  });

  final Color? cornerColor;
  final Color? lineColor;
  final Color? maskColor;
  final Color? maskColorOnTouchDown;
  final double ratio;
}

/// ImageEditorHandler 图片编辑器
class ImageEditor {
  _Helper? _helper;

  Future<EditedImage> cropImage() async {
    final helper = _helper;
    if (helper == null) {
      throw Exception('ImageEditorHandler is not initialized');
    }
    return helper.cropImage();
  }
}

class _Helper {
  _Helper(this.editorKey);

  final GlobalKey<ExtendedImageEditorState> editorKey;

  /// crop image
  Future<EditedImage> cropImage() async {
    final state = editorKey.currentState;
    if (state == null) {
      throw Exception('editorKey.currentState is null');
    }

    final cropRect = await _getCropRect(state);
    final data = state.rawImageData;

    final src = await compute(im.decodeImage, data);
    if (src == null) {
      throw Exception('图片解码失败');
    }

    final EditActionDetails editAction = state.editAction!;
    final frames = src.frames
        .map((e) => im.bakeOrientation(e))
        .map((e) => _copyCrop(e, editAction, cropRect))
        .map((e) => _flip(e, editAction))
        .map((e) => _copyRotate(e, editAction))
        .toList();
    src.frames = frames;

    return _encode(src);
  }

  Future<Rect> _getCropRect(ExtendedImageEditorState state) async {
    Rect cropRect = state.getCropRect()!;

    if (state.widget.extendedImageState.imageProvider is! ExtendedResizeImage) {
      return cropRect;
    }

    final ImmutableBuffer buffer = await ImmutableBuffer.fromUint8List(state.rawImageData);
    final ImageDescriptor descriptor = await ImageDescriptor.encoded(buffer);
    final double widthRatio = descriptor.width / state.image!.width;
    final double heightRatio = descriptor.height / state.image!.height;

    return Rect.fromLTRB(
      cropRect.left * widthRatio,
      cropRect.top * heightRatio,
      cropRect.right * widthRatio,
      cropRect.bottom * heightRatio,
    );
  }

  im.Image _flip(im.Image image, EditActionDetails action) {
    if (!action.needFlip) {
      return image;
    }

    im.FlipDirection mode;
    if (action.flipY && action.flipX) {
      mode = im.FlipDirection.both;
    } else if (action.flipY) {
      mode = im.FlipDirection.horizontal;
    } else if (action.flipX) {
      mode = im.FlipDirection.vertical;
    } else {
      mode = im.FlipDirection.both;
    }
    return im.flip(image, direction: mode);
  }

  im.Image _copyCrop(im.Image image, EditActionDetails action, Rect cropRect) {
    if (!action.needCrop) {
      return image;
    }

    return im.copyCrop(
      image,
      x: cropRect.left.toInt(),
      y: cropRect.top.toInt(),
      width: cropRect.width.toInt(),
      height: cropRect.height.toInt(),
    );
  }

  // copyRotate
  im.Image _copyRotate(im.Image image, EditActionDetails action) {
    if (!action.hasRotateAngle) {
      return image;
    }

    return im.copyRotate(image, angle: action.rotateAngle);
  }

  EditedImage _encode(im.Image src) {
    bool multiFrame = src.numFrames > 1;
    if (multiFrame) {
      return EditedImage(
        data: im.encodeGif(src),
        width: src.width,
        height: src.height,
        multiFrame: multiFrame,
      );
    } else {
      final frame = src.frames[0];
      return EditedImage(
        data: im.encodeJpg(frame),
        width: frame.width,
        height: frame.height,
        multiFrame: multiFrame,
      );
    }
  }
}

/// ImageEditorWidget 图片编辑器组件
class ImageEditorWidget extends StatefulWidget {
  ImageEditorWidget.file({
    required File file,
    required this.editor,
    super.key,
    this.opt = const ImageEditorOpt(),
    this.width,
    this.height,
    this.fit,
    double scale = 1.0,
  }) : image = ExtendedResizeImage.resizeIfNeeded(
          provider: ExtendedFileImageProvider(
            file,
            scale: scale,
            cacheRawData: true,
          ),
          cacheRawData: true,
        );

  ImageEditorWidget.network({
    required String url,
    required this.editor,
    super.key,
    this.opt = const ImageEditorOpt(),
    this.width,
    this.height,
    this.fit,
    double scale = 1.0,
  }) : image = ExtendedResizeImage.resizeIfNeeded(
          provider: ExtendedNetworkImageProvider(
            url,
            scale: scale,
            cacheRawData: true,
            retries: 3,
            cache: true,
            timeRetry: const Duration(milliseconds: 100),
          ),
          cacheRawData: true,
        );

  final ImageEditor editor;
  final ImageEditorOpt opt;
  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  State<ImageEditorWidget> createState() => _ImageEditorWidgetState();
}

class _ImageEditorWidgetState extends State<ImageEditorWidget> {
  final GlobalKey<ExtendedImageEditorState> editorKey = GlobalKey<ExtendedImageEditorState>();

  @override
  void initState() {
    super.initState();
    widget.editor._helper = _Helper(editorKey);
  }

  @override
  void dispose() {
    widget.editor._helper = null;
    super.dispose();
  }

  EditorConfig _getEditorConfig(BuildContext context) {
    final opt = widget.opt;
    return EditorConfig(
      maxScale: 4.0,
      cropRectPadding: const EdgeInsets.all(20),
      cornerSize: const Size(20, 3),
      hitTestSize: 20.0,
      cropAspectRatio: opt.ratio,
      cornerColor: opt.cornerColor,
      lineColor: opt.lineColor,
      editorMaskColorHandler: (context, pointerDown) {
        return pointerDown
            ? (opt.maskColorOnTouchDown ?? Colors.transparent)
            : (opt.maskColor ?? Colors.black.withOpacity(0.8));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedImage(
      image: widget.image,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      mode: ExtendedImageMode.editor,
      extendedImageEditorKey: editorKey,
      initEditorConfigHandler: (state) {
        return _getEditorConfig(context);
      },
    );
  }
}
