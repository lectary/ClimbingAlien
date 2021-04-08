import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:vector_math/vector_math.dart' as vec;

class ClimaxGhostPainter extends CustomPainter {
  final List<Tuple2<Rect, Rect>> limbsWithGhosts;
  final double? radius;
  final Color ghostColor;

  final double _ghostingOpacity = 0.5;
  final double _marginToPoint = 1.3;
  final double _arrowThickness = 2;

  ClimaxGhostPainter({required this.limbsWithGhosts, this.radius, this.ghostColor = Colors.grey});

  @override
  void paint(Canvas canvas, Size size) {
    Paint ghostPaint = Paint()
      ..style = PaintingStyle.stroke // obstacles are not filled
      ..strokeWidth = 3.0
      ..color = ghostColor.withOpacity(_ghostingOpacity);

    Paint arrowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _arrowThickness
      ..color = Colors.red;

    Paint arrowHeadPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = _arrowThickness
      ..color = Colors.red;

    limbsWithGhosts.forEach((Tuple2<Rect, Rect> tuple) {
      // Draws the ghost limb
      canvas.drawOval(tuple.item2, ghostPaint);

      // Calculate the offsets for a line between limb and ghost with some margin to them - simple vector math
      Offset offsetGhostToLimb = (tuple.item1.center - tuple.item2.center) / _marginToPoint + tuple.item2.center;
      Offset offsetLimbToGhost = (tuple.item2.center - tuple.item1.center) / _marginToPoint + tuple.item1.center;

      // TODO review - percentage is not ideal if the ghost is near the limb
      Offset startOfArrowHead = (tuple.item1.center - tuple.item2.center) / _marginToPoint * 1.025 + tuple.item2.center;
      Offset endOfArrowHead = (tuple.item1.center - tuple.item2.center) / _marginToPoint / 1.05 + tuple.item2.center;

      // Draws the arrow shaft
      canvas.drawLine(offsetGhostToLimb, offsetLimbToGhost, arrowPaint);
      // Draws the arrow head
      canvas.drawPath(getTrianglePath(startOfArrowHead, endOfArrowHead), arrowHeadPaint);
    });
  }

  Path getTrianglePath(Offset target, Offset source) {
    double x = target.dx;
    double y = target.dy;
    double x0 = source.dx;
    double y0 = source.dy;
    double angle = 135;

    // Rotating (x,y) around the (x0, y0) - normal rotation matrix formula with translation to the rotation angle
    double x1 = math.cos(vec.radians(angle)) * (x - x0) - math.sin(vec.radians(angle)) * (y0 - y);
    x1 = x1 + x0;
    double y1 = math.sin(vec.radians(angle)) * (x - x0) + math.cos(vec.radians(angle)) * (y0 - y);
    y1 = y0 - y1;

    double x2 = math.cos(vec.radians(360 - angle)) * (x - x0) - math.sin(vec.radians(360 - angle)) * (y0 - y);
    x2 = x2 + x0;
    double y2 = math.sin(vec.radians(360 - angle)) * (x - x0) + math.cos(vec.radians(360 - angle)) * (y0 - y);
    y2 = y0 - y2;

    return Path()
      ..moveTo(x, y)
      ..lineTo(x1, y1)
      ..lineTo(x2, y2)
      ..lineTo(x, y);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
