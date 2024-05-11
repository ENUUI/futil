import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:extended_image/extended_image.dart';

import '../win.dart';

class ImageViewerOpt extends ChangeNotifier {
  static ImageViewerOpt? of(BuildContext context) {
    try {
      return Provider.of<ImageViewerOpt>(context, listen: false);
    } catch (e) {
      return null;
    }
  }

  ImageViewerOpt({this.loadingIndicator});

  final Widget? loadingIndicator;
}

class ImageViewerWidget<T> extends StatefulWidget {
  const ImageViewerWidget({
    super.key,
    required this.images,
    required this.initIndex,
    this.heroTag,
    this.closeIcon,
    required this.useRootNavigator,
    this.onPageChanged,
  });

  final List<T> images;
  final int initIndex;
  final Object? heroTag;
  final Widget? closeIcon;
  final bool useRootNavigator;
  final void Function(int, int)? onPageChanged;

  @override
  State<StatefulWidget> createState() => _ImageViewerWidgetState();
}

class _ImageViewerWidgetState extends State<ImageViewerWidget> {
  final List<double> doubleTapScales = <double>[1.0, 2.0];
  final imageUrls = <String>[];
  final imageFiles = <File>[];
  int initIndex = 0;
  Object? indexHeroTag;
  late ExtendedPageController _pageController;

  int count = 0;

  @override
  void initState() {
    super.initState();

    final resources = widget.images;
    if (resources is List<String>) {
      imageUrls.addAll(resources);
    } else if (resources is List<String?>) {
      imageUrls.addAll(resources.where((e) => e != null && e.isNotEmpty).cast<String>());
    } else if (resources is List<File>) {
      imageFiles.addAll(resources);
    } else if (resources is List<File?>) {
      imageFiles.addAll(resources.where((e) => e != null).cast<File>());
    }

    indexHeroTag = widget.heroTag;

    if (imageUrls.isNotEmpty) {
      count = imageUrls.length;
      initIndex = min(widget.initIndex, imageUrls.length - 1);
    } else if (imageFiles.isNotEmpty) {
      count = imageFiles.length;
      initIndex = min(widget.initIndex, imageFiles.length - 1);
    }
    _pageController = ExtendedPageController(initialPage: initIndex)..addListener(_onListenPageController);
    widget.onPageChanged?.call(initIndex, count);
  }

  void _onListenPageController() {
    widget.onPageChanged?.call(_pageController.page?.round() ?? 0, count);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDoubleTap(ExtendedImageGestureState state) {
    final pointerDownPosition = state.pointerDownPosition;
    final begin = state.gestureDetails?.totalScale ?? 1.0;
    double end;

    if (begin == doubleTapScales[0]) {
      end = doubleTapScales[1];
    } else {
      end = doubleTapScales[0];
    }

    state.handleDoubleTap(scale: end, doubleTapPosition: pointerDownPosition);
  }

  GestureConfig _initGestureConfigHandler(ExtendedImageState state) {
    return GestureConfig(
      minScale: 0.9,
      animationMinScale: 0.7,
      maxScale: 2.0,
      animationMaxScale: 2.5,
      speed: 1.0,
      inertialSpeed: 100.0,
      initialScale: 1.0,
      inPageView: true,
      initialAlignment: InitialAlignment.center,
    );
  }

  Widget _buildWebImage(BuildContext context, int index) {
    final url = imageUrls[index];

    Widget webImage = ExtendedImage.network(
      url,
      fit: BoxFit.contain,
      mode: ExtendedImageMode.gesture,
      constraints: BoxConstraints(
        maxWidth: Win.width(context),
        maxHeight: Win.height(context),
      ),
      initGestureConfigHandler: _initGestureConfigHandler,
      onDoubleTap: _onDoubleTap,
      loadStateChanged: (state) {
        if (state.extendedImageLoadState == LoadState.completed) {
          return null;
        }

        if (state.extendedImageLoadState == LoadState.loading) {
          return ImageViewerOpt.of(context)?.loadingIndicator ?? const SizedBox();
        }

        return null;
      },
    );
    if (indexHeroTag != null && initIndex == index) {
      webImage = Hero(tag: indexHeroTag!, child: webImage);
    }
    return webImage;
  }

  Widget _buildWebImagePages() {
    return ExtendedImageGesturePageView.builder(
      controller: _pageController,
      itemCount: imageUrls.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: _buildWebImage,
    );
  }

  Widget _buildFileImage(BuildContext context, int index) {
    final file = imageFiles[index];

    Widget fileImage = ExtendedImage.file(
      file,
      fit: BoxFit.contain,
      mode: ExtendedImageMode.gesture,
      constraints: BoxConstraints(
        maxWidth: Win.width(context),
        maxHeight: Win.height(context),
      ),
      initGestureConfigHandler: _initGestureConfigHandler,
      onDoubleTap: _onDoubleTap,
    );
    if (indexHeroTag != null && initIndex == index) {
      fileImage = Hero(tag: indexHeroTag!, child: fileImage);
    }
    return fileImage;
  }

  Widget _buildFromFiles() {
    return ExtendedImageGesturePageView.builder(
      controller: _pageController,
      itemBuilder: _buildFileImage,
      scrollDirection: Axis.horizontal,
      itemCount: imageFiles.length,
    );
  }

  Widget _buildPageView() {
    Widget child;

    if (imageUrls.isNotEmpty) {
      child = _buildWebImagePages();
    } else if (imageFiles.isNotEmpty) {
      child = _buildFromFiles();
    } else {
      child = Container();
    }

    return Positioned.fill(child: child);
  }

  @override
  Widget build(BuildContext context) {
    return _buildPageView();
  }
}
