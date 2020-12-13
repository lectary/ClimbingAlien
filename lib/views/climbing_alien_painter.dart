import 'package:flutter/material.dart';

class ClimbingAlienPainter extends CustomPainter {
  final Offset position;

  ClimbingAlienPainter({this.position});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.amber;
    paint.strokeWidth = 5;

    canvas.drawCircle(position, size.height / 16, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
