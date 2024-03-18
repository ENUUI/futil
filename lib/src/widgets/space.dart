import 'package:flutter/material.dart';

class Blank extends StatelessWidget {
  const Blank({
    super.key,
    this.width = 0,
    this.height = 0,
    this.color,
  });

  const Blank.horizontal({
    super.key,
    double size = 0,
  })  : color = null,
        height = 0,
        width = size;

  const Blank.vertical({
    super.key,
    double size = 0,
  })  : color = null,
        width = 0,
        height = size;

  const Blank.v(double size, {super.key})
      : color = null,
        width = 0,
        height = size;

  const Blank.h(double size, {super.key})
      : color = null,
        width = size,
        height = 0;

  final double width;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (color != null && width > 0 && height > 0) {
      return SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          size: Size(width, height),
          painter: _BlankPainter(color: color!),
        ),
      );
    }

    return SizedBox(width: width, height: height);
  }
}

class _BlankPainter extends CustomPainter {
  const _BlankPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final Rect rect = Offset.zero & size;
    final Path path = Path()..addRect(rect);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BlankPainter oldPainter) {
    return oldPainter.color != color;
  }

  @override
  bool hitTest(Offset position) => false;
}
