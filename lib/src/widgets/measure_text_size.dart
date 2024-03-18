import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class MeasureTextSize {
  MeasureTextSize({
    this.textAlign = TextAlign.start,
    this.textDirection = TextDirection.ltr,
    this.textScaleFactor = 1.0,
    this.maxLines,
    this.ellipsis,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
  });

  final TextAlign textAlign;
  final TextDirection? textDirection;
  final double textScaleFactor;
  final int? maxLines;
  final String? ellipsis;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final ui.TextHeightBehavior? textHeightBehavior;

  TextPainter _textPainter(TextSpan text) {
    return TextPainter(
      text: text,
      textAlign: textAlign,
      textDirection: textDirection,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      ellipsis: ellipsis,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }

  double _windowMaxWidth() => MediaQueryData.fromView(ui.window).size.width;

  Size measureTextSpan({required TextSpan text, double? maxWidth}) {
    maxWidth ??= _windowMaxWidth();
    if (maxWidth == 0) {
      return Size.zero;
    }
    final painter = _textPainter(text);
    painter.layout(maxWidth: maxWidth);
    final size = painter.size;
    painter.dispose();
    return size;
  }

  Size measureText({required String text, TextStyle? textStyle, double? maxWidth}) {
    maxWidth ??= _windowMaxWidth();
    if (maxWidth == 0) {
      return Size.zero;
    }
    final painter = _textPainter(TextSpan(text: text, style: textStyle));
    painter.layout(maxWidth: maxWidth);
    final size = painter.size;
    painter.dispose();
    return size;
  }

  bool textExceedMaxLines({required String text, TextStyle? textStyle, double? maxWidth}) {
    maxWidth ??= _windowMaxWidth();
    if (maxWidth == 0) {
      return false;
    }
    final painter = _textPainter(TextSpan(text: text, style: textStyle));
    painter.layout(maxWidth: maxWidth);
    final exceed = painter.didExceedMaxLines;
    painter.dispose();
    return exceed;
  }

  bool textSpanExceedMaxLines({required TextSpan text, double? maxWidth}) {
    maxWidth ??= _windowMaxWidth();
    if (maxWidth == 0) {
      return false;
    }
    final painter = _textPainter(text);
    painter.layout(maxWidth: maxWidth);
    final exceed = painter.didExceedMaxLines;
    painter.dispose();
    return exceed;
  }
}
