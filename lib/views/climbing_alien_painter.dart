import 'dart:math';

import 'package:climbing_alien/utils/utils.dart';
import 'package:flutter/material.dart';

/// Class for drawing Climax, the Cli-mbing max-erl.
class ClimbingAlienPainter extends CustomPainter {
  final Offset position;

  ClimbingAlienPainter({this.position});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.amber;

    // body
    var bodyRect = Rect.fromCenter(center: position, width: 50, height: 80);
    canvas.drawOval(bodyRect, paint);

    // limbs
    var circleBottomLeftCenter = position + Offset(-50, 70);
    var circleBottomRightCenter = position + Offset(50, 70);
    var circleTopLeftCenter = position + Offset(-50, -70);
    var circleTopRightCenter = position + Offset(50, -70);
    var radius = 20.0;

    paint.style = PaintingStyle.stroke; // obstacles are not filled
    paint.strokeWidth = 3.0;
    canvas.drawCircle(circleBottomLeftCenter, radius, paint);
    canvas.drawCircle(circleBottomRightCenter, radius, paint);
    canvas.drawCircle(circleTopLeftCenter, radius, paint);
    canvas.drawCircle(circleTopRightCenter, radius, paint);

    // arms
    Offset offsetForPointOnBorderBottomLeft = Offset(cos(Utils.degreesToRadians(45)) * radius, -cos(Utils.degreesToRadians(45)) * radius);
    canvas.drawLine(circleBottomLeftCenter + offsetForPointOnBorderBottomLeft, position, paint);

    Offset offsetForPointOnBorderBottomRight = Offset(-cos(Utils.degreesToRadians(45)) * radius, -cos(Utils.degreesToRadians(45)) * radius);
    canvas.drawLine(circleBottomRightCenter + offsetForPointOnBorderBottomRight, position, paint);

    Offset offsetForPointOnBorderTopLeft = Offset(cos(Utils.degreesToRadians(45)) * radius, cos(Utils.degreesToRadians(45)) * radius);
    canvas.drawLine(circleTopLeftCenter + offsetForPointOnBorderTopLeft, position, paint);

    Offset offsetForPointOnBorderTopRight = Offset(-cos(Utils.degreesToRadians(45)) * radius, cos(Utils.degreesToRadians(45)) * radius);
    canvas.drawLine(circleTopRightCenter + offsetForPointOnBorderTopRight, position, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
