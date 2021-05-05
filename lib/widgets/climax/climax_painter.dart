import 'dart:math';

import 'package:climbing_alien/utils/utils.dart';
import 'package:climbing_alien/shared/climax_viewmodel.dart';
import 'package:flutter/material.dart';

/// [CustomPainter] class for drawing Climax, the Cli-mbing max-erl.
class ClimaxPainter extends CustomPainter {
  final Map<ClimaxLimbEnum, Rect>? limbs;
  final double? radius;
  final ClimaxLimbEnum? selectedLimb;
  final Color climaxColor;
  final Color selectionColor;

  ClimaxPainter(
      {this.limbs, this.radius, this.climaxColor = Colors.amber, this.selectedLimb, this.selectionColor = Colors.red});

  @override
  void paint(Canvas canvas, Size size) {
    Paint defaultColorPaint = Paint()
      ..style = PaintingStyle.stroke // obstacles are not filled
      ..strokeWidth = 3.0
      ..color = climaxColor;

    Paint bodyColorPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = climaxColor;

    Paint selectedColorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = selectionColor;

    if (limbs == null) return;

    limbs!.entries.forEach((entry) {
      if (entry.key == ClimaxLimbEnum.BODY) {
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

    // Calculates and draws the line from climax body center to the edge of the corresponding limb.
    // The corresponding point on the edge, is the point that is, based on the original limb position (which means, that subsequent position updates does NOT affect this),
    // on the circle with an angular of 45 degrees.
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
