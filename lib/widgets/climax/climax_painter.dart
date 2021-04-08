import 'dart:math';

import 'package:climbing_alien/utils/utils.dart';
import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:flutter/material.dart';

/// Class for drawing Climax, the Cli-mbing max-erl.
class ClimaxPainter extends CustomPainter {
  final Map<ClimaxLimbEnum, Rect>? limbs;
  final double? radius;
  final ClimaxLimbEnum? selectedLimb;
  final Color color;
  final bool isGhost;

  final double _ghostingOpacity = 0.5;

  ClimaxPainter({this.limbs, this.radius, this.selectedLimb, this.color = Colors.amber, this.isGhost = false});

  @override
  void paint(Canvas canvas, Size size) {
    Paint defaultColorPaint = Paint()
      ..style = PaintingStyle.stroke // obstacles are not filled
      ..strokeWidth = 3.0
      ..color = isGhost ? color.withOpacity(_ghostingOpacity) : color;

    Paint bodyColorPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isGhost ? color.withOpacity(_ghostingOpacity) : color;

    Paint selectedColorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = Colors.red;

    if (limbs == null) return;

    limbs!.entries.forEach((entry) {
      if (entry.key == ClimaxLimbEnum.BODY && !isGhost) {
        final body = entry;
        // Check whether body is overlapping with a limb to make it transparent
        if (limbs!.entries.any((limb) => limb.key != ClimaxLimbEnum.BODY && limb.value.overlaps(body.value))) {
          canvas.drawOval(entry.value, bodyColorPaint..color = bodyColorPaint.color.withOpacity(0.5));
        } else {
          canvas.drawOval(entry.value, bodyColorPaint..color = bodyColorPaint.color.withOpacity(1));
        }
      } else {
        canvas.drawOval(entry.value, entry.key == selectedLimb ? selectedColorPaint : defaultColorPaint);
      }
    });

    var position = limbs![ClimaxLimbEnum.BODY]!.center;

    Offset offsetForPointOnBorderTopLeft =
        Offset(cos(Utils.degreesToRadians(45)) * radius!, cos(Utils.degreesToRadians(45)) * radius!);
    canvas.drawLine(
        limbs![ClimaxLimbEnum.LEFT_ARM]!.center + offsetForPointOnBorderTopLeft, position, defaultColorPaint);

    Offset offsetForPointOnBorderTopRight =
        Offset(-cos(Utils.degreesToRadians(45)) * radius!, cos(Utils.degreesToRadians(45)) * radius!);
    canvas.drawLine(
        limbs![ClimaxLimbEnum.RIGHT_ARM]!.center + offsetForPointOnBorderTopRight, position, defaultColorPaint);

    Offset offsetForPointOnBorderBottomLeft =
        Offset(cos(Utils.degreesToRadians(45)) * radius!, -cos(Utils.degreesToRadians(45)) * radius!);
    canvas.drawLine(
        limbs![ClimaxLimbEnum.LEFT_LEG]!.center + offsetForPointOnBorderBottomLeft, position, defaultColorPaint);

    Offset offsetForPointOnBorderBottomRight =
        Offset(-cos(Utils.degreesToRadians(45)) * radius!, -cos(Utils.degreesToRadians(45)) * radius!);
    canvas.drawLine(
        limbs![ClimaxLimbEnum.RIGHT_LEG]!.center + offsetForPointOnBorderBottomRight, position, defaultColorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
