import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:futil/src/win.dart';
import 'package:provider/provider.dart';

class WebImageConf extends ChangeNotifier {
  WebImageConf({this.placeholderWidgetBuilder, this.errorWidget});

  static WebImageConf of(BuildContext context) {
    return Provider.of<WebImageConf>(context);
  }

  final LoadingErrorWidgetBuilder? errorWidget;
  final PlaceholderWidgetBuilder? placeholderWidgetBuilder;
}

class WebImage extends StatelessWidget {
  static CachedNetworkImageProvider provider(
    String url, {
    int? maxWidth,
    int? maxHeight,
    double scale = 1.0,
    Map<String, String>? headers,
    String? cacheKey,
  }) =>
      // TODO: 定制重试策略
      CachedNetworkImageProvider(
        url,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        scale: scale,
        headers: headers,
        cacheKey: cacheKey,
      );

  const WebImage({
    super.key,
    required this.url,
    this.errorWidget,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.placeholderWidgetBuilder,
    this.fadeInDuration = const Duration(),
    this.fadeOutDuration = const Duration(),
    this.needTryClip = true,
  });

  final String url;
  final bool needTryClip;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final LoadingErrorWidgetBuilder? errorWidget;
  final PlaceholderWidgetBuilder? placeholderWidgetBuilder;

  Widget _retryErrorBuilder(BuildContext context, String url, dynamic error) {
    return _buildImageWithUrl(
      context,
      this.url,
      errorWidgetBuilder: _errorBuilder(),
    );
  }

  LoadingErrorWidgetBuilder _errorBuilder() {
    return errorWidget ??
        (BuildContext context, String url, dynamic error) {
          return const SizedBox();
        };
  }

  Widget _buildImageWithUrl(BuildContext context, String imageUrl,
      {LoadingErrorWidgetBuilder? errorWidgetBuilder}) {
    final conf = WebImageConf.of(context);

    return CachedNetworkImage(
      imageUrl: imageUrl,
      errorWidget: errorWidgetBuilder ?? conf.errorWidget,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: fadeOutDuration,
      placeholder: placeholderWidgetBuilder ?? conf.placeholderWidgetBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final clipUrl = QImageSrc(context,
            clipHeight: width ?? 300.0, clipWidth: height ?? 300.0)
        .imageSrc(url);
    if (clipUrl.isEmpty && url.isEmpty) {
      return (errorWidget ?? WebImageConf.of(context).errorWidget)
              ?.call(context, '', ArgumentError('image url is empty')) ??
          SizedBox(width: width, height: height);
    }

    final imageUrl = needTryClip ? clipUrl : url;
    return _buildImageWithUrl(
      context,
      imageUrl,
      errorWidgetBuilder: needTryClip ? _retryErrorBuilder : _errorBuilder(),
    );
  }
}

class QImageSrc {
  const QImageSrc(
    this.context, {
    required this.clipHeight,
    required this.clipWidth,
  });

  final BuildContext context;
  final double clipWidth;
  final double clipHeight;

  String imageSrc(String src) {
    if (src.isEmpty) return src;

    return src + extraParams(src);
  }

  String extraParams(String src) {
    if (src.isEmpty) return src;
    final r = _getRect();
    return _sizedNetImage(src, w: r.w, h: r.h);
  }

  String _sizedNetImage(String url, {required int w, required int h}) {
    if (url.isEmpty) return url;
    if (w <= 0 || h <= 0) return url;

    var resizeParam = '/resize,m_mfit,w_$w,h_$h';
    if (url.contains(ossProcessParamKey)) {
    } else {
      resizeParam = '?$ossProcessParamKey=image$resizeParam';
    }
    return resizeParam;
  }

  _Rect _getRect({double scale = 1.0, double maxSize = 4096}) {
    final key = 'w_$clipWidth _ h_$clipHeight';
    if (_rectCache[key] != null) {
      return _rectCache[key]!;
    }

    final ratio = _getRatio();

    var w = 0;
    var h = 0;

    final realW = clipWidth * ratio * scale;
    final realH = clipHeight * ratio * scale;

    final s = math.max(realW / maxSize, realH / maxSize);

    if (s <= 0) {
    } else if (s <= 1) {
      w = realW.floor();
      h = realH.floor();
    } else if (s <= 1.25) {
      w = (realW / s).floor();
      h = (realH / s).floor();
    }

    final r = _Rect(w: w, h: h);
    _rectCache[key] = r;
    return r;
  }

  double _getRatio() {
    return Win.pixelRatio(context);
  }

  static final Map<String, _Rect> _rectCache = <String, _Rect>{};
}

const ossProcessParamKey = 'x-oss-process';

class _Rect {
  _Rect({required this.w, required this.h});

  final int w;
  final int h;
}
