import 'dart:math' as _math;

import 'package:flutter/material.dart';

class Joystick2 extends StatefulWidget {
  final double size = 100;

  @override
  _Joystick2State createState() => _Joystick2State();
}

class _Joystick2State extends State<Joystick2> {
  double stickSize;
  Offset stickPosition;
  Offset lastPosition;

  @override
  void initState() {
    super.initState();
    stickSize = widget.size / 2;
    lastPosition = Offset(stickSize, stickSize);
    stickPosition = updatePosition(lastPosition, Offset.zero);
  }

  Offset updatePosition(Offset lastPosition, Offset offset) {
    double middle = widget.size / 2.0;

    double angle = _math.atan2(offset.dy - middle, offset.dx - middle);
    double degrees = angle * 180 / _math.pi;
    if (offset.dx < middle && offset.dy < middle) {
      degrees = 360 + degrees;
    }
    bool isStartPosition = lastPosition.dx == stickSize && lastPosition.dy == stickSize;
    double lastAngleRadians = (isStartPosition) ? 0 : (degrees) * (_math.pi / 180.0);

    var rBig = widget.size / 2;
    var rSmall = stickSize / 2;

    var x = (lastAngleRadians == -1) ? rBig - rSmall : (rBig - rSmall) + (rBig - rSmall) * _math.cos(lastAngleRadians);
    var y = (lastAngleRadians == -1) ? rBig - rSmall : (rBig - rSmall) + (rBig - rSmall) * _math.sin(lastAngleRadians);

    var xPosition = lastPosition.dx - rSmall;
    var yPosition = lastPosition.dy - rSmall;

    var angleRadianPlus = lastAngleRadians + _math.pi / 2;
    if (angleRadianPlus < _math.pi / 2) {
      if (xPosition > x) {
        xPosition = x;
      }
      if (yPosition < y) {
        yPosition = y;
      }
    } else if (angleRadianPlus < _math.pi) {
      if (xPosition > x) {
        xPosition = x;
      }
      if (yPosition > y) {
        yPosition = y;
      }
    } else if (angleRadianPlus < 3 * _math.pi / 2) {
      if (xPosition < x) {
        xPosition = x;
      }
      if (yPosition > y) {
        yPosition = y;
      }
    } else {
      if (xPosition < x) {
        xPosition = x;
      }
      if (yPosition < y) {
        yPosition = y;
      }
    }
    return Offset(xPosition, yPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
        color: Colors.grey,
        child: GestureDetector(
          onPanStart: (details) {
            setState(() => lastPosition = details.localPosition);
          },
          onPanUpdate: (details) =>
              setState(() {
                stickPosition = updatePosition(lastPosition, details.localPosition);
                lastPosition = details.localPosition;
              }),
          onPanEnd: (details) =>
              setState(() {
                stickPosition = updatePosition(Offset(stickSize, stickSize), Offset.zero);
                lastPosition = Offset(stickSize, stickSize);
              }),
          child: Stack(
            children: [
              Align(alignment: Alignment.topCenter, child: Icon(Icons.keyboard_arrow_up)),
              Align(alignment: Alignment.bottomCenter, child: Icon(Icons.keyboard_arrow_down)),
              Align(alignment: Alignment.centerLeft, child: Icon(Icons.keyboard_arrow_left)),
              Align(alignment: Alignment.centerRight, child: Icon(Icons.keyboard_arrow_right)),
              Positioned(
                top: stickPosition.dy,
                left: stickPosition.dx,
                child: Opacity(
                  opacity: 1,
                  child: Container(
                    width: widget.size / 2,
                    height: widget.size / 2,
                    decoration: BoxDecoration(color: Colors.grey[600], shape: BoxShape.circle),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
