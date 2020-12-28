import 'dart:math';

import 'package:climbing_alien/utils/utils.dart';
import 'package:flutter/material.dart';

/// Class for drawing Climax, the Cli-mbing max-erl.
class ClimaxPainter extends CustomPainter {
  final List<Rect> limbs;
  final selectedIndex;

  ClimaxPainter({this.limbs, this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    Paint defaultColorPaint = Paint()
      ..style = PaintingStyle.stroke // obstacles are not filled
      ..strokeWidth = 3.0
      ..color = Colors.amber;

    Paint selectedColorPaint = Paint()
      ..style = PaintingStyle.stroke // obstacles are not filled
      ..strokeWidth = 5.0
      ..color = Colors.red;

    var i = 0;
    for (Rect rect in limbs) {
      canvas.drawOval(rect, i++ == selectedIndex ? selectedColorPaint : defaultColorPaint);
    }

    var radius = limbs[1].width / 2;
    var position = limbs[0].center;

    Offset offsetForPointOnBorderTopLeft =
        Offset(cos(Utils.degreesToRadians(45)) * radius, cos(Utils.degreesToRadians(45)) * radius);
    canvas.drawLine(limbs[1].center + offsetForPointOnBorderTopLeft, position, defaultColorPaint);

    Offset offsetForPointOnBorderTopRight =
        Offset(-cos(Utils.degreesToRadians(45)) * radius, cos(Utils.degreesToRadians(45)) * radius);
    canvas.drawLine(limbs[2].center + offsetForPointOnBorderTopRight, position, defaultColorPaint);

    Offset offsetForPointOnBorderBottomLeft =
        Offset(cos(Utils.degreesToRadians(45)) * radius, -cos(Utils.degreesToRadians(45)) * radius);
    canvas.drawLine(limbs[3].center + offsetForPointOnBorderBottomLeft, position, defaultColorPaint);

    Offset offsetForPointOnBorderBottomRight =
        Offset(-cos(Utils.degreesToRadians(45)) * radius, -cos(Utils.degreesToRadians(45)) * radius);
    canvas.drawLine(limbs[4].center + offsetForPointOnBorderBottomRight, position, defaultColorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
