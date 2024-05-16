import 'dart:convert';

import 'package:flutter/material.dart';

class Base64Image extends StatelessWidget {
  const Base64Image({super.key, required this.data, this.width, this.height, this.fit});
  final String data;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return Image.memory(base64Decode(data), width: width, height: height, fit: fit);
  }
}
