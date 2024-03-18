import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Win {
  Win._();

  static List<DeviceOrientation> get appMainOrientations => [DeviceOrientation.portraitUp];

  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double statusBar(BuildContext context) {
    return MediaQuery.of(context).viewPadding.top;
  }

  static double bottomSafe(BuildContext context) {
    return MediaQuery.of(context).viewPadding.bottom;
  }

  static double pixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }
}
