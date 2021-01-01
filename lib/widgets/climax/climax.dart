
import 'dart:developer';

import 'package:climbing_alien/widgets/climax/climax_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum ClimaxLimb {
  LEFT_ARM,
  RIGHT_ARM,
  LEFT_FOOT,
  RIGHT_FOOT,
}

class Climax extends StatefulWidget {
  final Offset position;
  final int selection;

  Climax({this.position, this.selection, Key key}) : super(key: key);

  @override
  _ClimaxState createState() => _ClimaxState();
}

class _ClimaxState extends State<Climax> {
  Rect bodyRect;
  Rect leftArmRect;
  Rect rightArmRect;
  Rect leftLegRect;
  Rect rightLegRect;

  int selectedIndex = -1;

  @override
  void didUpdateWidget(Climax oldWidget) {
    super.didUpdateWidget(oldWidget);
    this.selectedIndex = widget.selection;
  }

  @override
  Widget build(BuildContext context) {
    final radius = 20.0;
    bodyRect = Rect.fromCenter(center: widget.position, width: 50, height: 80);
    leftArmRect = Rect.fromCircle(center: widget.position + Offset(-50, -70), radius: radius);
    rightArmRect = Rect.fromCircle(center: widget.position + Offset(50, -70), radius: radius);
    leftLegRect = Rect.fromCircle(center: widget.position + Offset(-50, 70), radius: radius);
    rightLegRect = Rect.fromCircle(center: widget.position + Offset(50, 70), radius: radius);
    final limbs = [bodyRect, leftArmRect, rightArmRect, leftLegRect, rightLegRect];

    return GestureDetector(
      onTapDown: (details) {
        RenderBox box = context.findRenderObject();
        final offset = box.globalToLocal(details.globalPosition);
        setState(() {
          selectedIndex = limbs.lastIndexWhere((limb) => limb.contains(offset));
          log("Index: $selectedIndex");
        });
      },
      child: CustomPaint(
        // painter: ClimaxPainter(body: bodyRect, leftArm: leftArmRect, rightArm: rightArmRect, leftLeg: leftLegRect, rightLeg: rightLegRect, selectedIndex),
        painter: ClimaxPainter(limbs: limbs, selectedIndex: selectedIndex),
      ),
    );
  }
}
