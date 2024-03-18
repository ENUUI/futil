import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:extended_image/extended_image.dart';

import '../win.dart';

class ImageViewerOptions<T> {
  ImageViewerOptions({required this.images, this.initIndex = 0, this.heroTag});

  final List<T> images;
  final int initIndex;
  final Object? heroTag;
}

class ImageViewer<T> extends StatefulWidget {
  final List<T> images;
  final int initIndex;
  final Object? heroTag;
  final Widget? closeIcon;
  final bool useRootNavigator;

  const ImageViewer({
    super.key,
    required this.images,
    required this.initIndex,
    this.heroTag,
    this.closeIcon,
    required this.useRootNavigator,
  });

  @override
  State<StatefulWidget> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final List<double> doubleTapScales = <double>[1.0, 2.0];
  final imageUrls = <String>[];
  final imageFiles = <File>[];
  int initIndex = 0;
  Object? indexHeroTag;
  _Counter? _counter;
  late ExtendedPageController _pageController;

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
      initIndex = min(widget.initIndex, imageUrls.length - 1);
      _counter = _Counter(initIndex: initIndex, maxCount: imageUrls.length);
    } else if (imageFiles.isNotEmpty) {
      initIndex = min(widget.initIndex, imageFiles.length - 1);
      _counter = _Counter(initIndex: initIndex, maxCount: imageFiles.length);
    }

    if (_counter != null) {
      _pageController = ExtendedPageController(initialPage: initIndex)..addListener(_onListenPageController);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _close() {
    Navigator.of(context, rootNavigator: widget.useRootNavigator).maybePop();
  }

  void _onListenPageController() {
    _counter?.currentIndex = _pageController.page?.round() ?? 0;
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

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () {
        _close();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52.0,
        width: 44.0,
        alignment: Alignment.center,
        child: widget.closeIcon ?? const Icon(Icons.close, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildCounter() {
    return Center(
      child: ChangeNotifierProvider(
        create: (_) => _counter,
        child: const _CounterLabel(),
      ),
    );
  }

  Widget _buildActionNavBar() {
    final children = <Widget>[];

    children.add(_buildCloseButton());

    if (_counter != null) {
      children.add(Expanded(child: _buildCounter()));
    }

    children.add(const SizedBox(width: 44.0));
    Widget bar = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );

    final height = 52.0 + Win.statusBar(context);

    bar = Container(
      height: height,
      padding: EdgeInsets.only(
        top: Win.statusBar(context),
        left: 10.0,
        right: 10.0,
      ),
      alignment: Alignment.bottomCenter,
      child: bar,
    );

    return Positioned(
      top: 0.0,
      right: 0.0,
      left: 0.0,
      child: bar,
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
          print('->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${ImageViewerOpt.of(context)}');
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
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: GestureDetector(
        onTap: () {
          _close();
        },
        child: Stack(
          children: <Widget>[
            _buildPageView(),
            _buildActionNavBar(),
          ],
        ),
      ),
    );
  }
}

class _Counter extends ChangeNotifier {
  _Counter({int initIndex = 0, required this.maxCount}) : _currentIndex = initIndex;

  final int maxCount;

  int get currentIndex => _currentIndex;
  int _currentIndex = 0;

  set currentIndex(int newIndex) {
    if (_currentIndex == newIndex) return;

    _currentIndex = newIndex;
    notifyListeners();
  }

  String get indexLabel => '${currentIndex + 1}/$maxCount';
}

class _CounterLabel extends StatelessWidget {
  const _CounterLabel();

  @override
  Widget build(BuildContext context) {
    return Consumer<_Counter>(builder: (ctx, model, _) {
      return Text(
        model.indexLabel,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      );
    });
  }
}

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
