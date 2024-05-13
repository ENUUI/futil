import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:extended_image/extended_image.dart';

import '../win.dart';
import 'image_viewer_widget.dart';

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
    _counter = _Counter();

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
    } else if (imageFiles.isNotEmpty) {
      initIndex = min(widget.initIndex, imageFiles.length - 1);
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

    return bar;
  }

  Widget _buildPageView() {
    return ImageViewerWidget(
      images: widget.images,
      initIndex: initIndex,
      heroTag: widget.heroTag,
      closeIcon: widget.closeIcon,
      onPageChanged: (index, count) {
        _counter?.setCurrentIndex(index, count);
      },
    );
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
            Positioned.fill(child: _buildPageView()),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: _buildActionNavBar(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Counter extends ChangeNotifier {
  int _maxCount = 0;

  int get currentIndex => _currentIndex;
  int _currentIndex = 0;

  void setCurrentIndex(int newIndex, int count) {
    if (_currentIndex == newIndex && _maxCount == count) return;

    _currentIndex = newIndex;
    _maxCount = count;
    notifyListeners();
  }

  String get indexLabel => '${currentIndex + 1}/$_maxCount';
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
