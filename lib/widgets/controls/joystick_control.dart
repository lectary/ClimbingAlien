import 'dart:math' as _math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef JoystickDirectionCallback = void Function(double degrees, double distance);

const defaultSize = 100.0;
const defaultStickSize = 50.0;

class JoystickWithControlButtons extends StatefulWidget {
  final double size;
  final double sizeControlStick;
  final JoystickDirectionCallback onDirectionChanged;
  final Color colorBackground;
  final Color colorControlStick;
  final Color colorIcon;

  final Function onClickedUp;
  final Function onClickedDown;
  final Function onClickedLeft;
  final Function onClickedRight;

  JoystickWithControlButtons(
      {this.size = defaultSize,
      this.sizeControlStick = defaultStickSize,
      this.onDirectionChanged,
      this.colorBackground = Colors.grey,
      this.colorControlStick = Colors.blueGrey,
      this.colorIcon = Colors.white,
      this.onClickedUp,
      this.onClickedDown,
      this.onClickedLeft,
      this.onClickedRight,
      Key key})
      : super(key: key);

  @override
  _JoystickWithControlButtonsState createState() => _JoystickWithControlButtonsState();
}

class _JoystickWithControlButtonsState extends State<JoystickWithControlButtons> {
  double outerSize;
  double controlStickSize;
  Offset controlStickPosition;
  Offset center;

  @override
  void initState() {
    super.initState();
    outerSize = widget.size;
    controlStickSize = widget.sizeControlStick;
    center = Offset(outerSize / 2, outerSize / 2);
    controlStickPosition = calculateControlStickPosition(center);
  }

  /// Calculates and calls the passed callback with the corresponding data.
  ///
  /// Returns the radius of the stick analogues to a clock, and how far it is pulled away from center.
  void processCallback(Offset offset) {
    double smallRadius = controlStickSize / 2.0;
    double bigRadius = outerSize / 2.0;

    Offset shiftedOffset = (offset - center); // Shift to get the offset with the center as origin.
    double angle = _math.atan2(shiftedOffset.dy, shiftedOffset.dx); // Calculates the angle in radians between x-axis and the point.
    // Correcting degrees interval to [0, 360]. The interval starts analogues to a clock at 12 and runs clockwise.
    double degrees = (angle * 180 / _math.pi + 90);
    if (offset.dx < bigRadius && offset.dy < bigRadius) {
      degrees = 360 + degrees;
    }

    // Calculating distance how far the stick is pulled towards the outer border, normalized to [0,1]
    double distance = (offset - center).distance;
    double normalizedDistance = _math.min(distance / (bigRadius - smallRadius), 1.0);

    if (widget.onDirectionChanged != null) {
      widget.onDirectionChanged(degrees, normalizedDistance);
    }
  }

  /// Calculates the new position of the control stick.
  ///
  /// The calculation considers that [Positioned] starts from the top left corner of a widget, not the center.
  Offset calculateControlStickPosition(Offset offset) {
    double smallRadius = controlStickSize / 2.0;
    double bigRadius = outerSize / 2.0;

    double maxDistance = outerSize / 2.0 - smallRadius; // Max. distance the stick should go, i.e. till it touches outer circle.

    Offset shiftedOffset = (offset - center); // Shift to get the offset with the center as origin.
    double angle = _math.atan2(shiftedOffset.dy, shiftedOffset.dx); // Calculates the angle in radians between x-axis and the point.
    double degrees = (angle * 180 / _math.pi); // Convert to degrees, results are in interval [-180, 180].
    // Correcting degrees interval to [0, 360].
    if (offset.dy < bigRadius) {
      degrees = 360 + degrees;
    }

    // Calculate points o (x,y) with the center as origin, results are in interval [-(size-stickSize)/2, +(size-stickSize)/2}.
    // The positions are the distance from the center of the widget to the center of the control stick,
    // so that he touches the outer circle.
    var x = maxDistance * _math.cos(angle);
    var y = maxDistance * _math.sin(angle);

    // Offset corrected by radius of the controlStick, because the position needs to be calculated based on
    // the sticks top-left corner, not center (due to behaviour of Positioned-Widget).
    var posX = offset.dx - smallRadius;
    var posY = offset.dy - smallRadius;

    // Further restrict the position to stay within the outer circle.
    double newDistance = (offset - center).distance;
    // (bigRadius - smallRadius) must be added as correction, due to the fact, that the final offset must be
    // positioned with the origin in the top-left corner of the widget.
    if (newDistance > maxDistance) {
      posX = x + (bigRadius - smallRadius);
      posY = y + (bigRadius - smallRadius);
    }

    return Offset(posX, posY);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: outerSize,
      height: outerSize,
      child: Material(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0), side: BorderSide(width: 2.0, color: widget.colorControlStick)),
        color: widget.colorBackground,
        child: GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onPanUpdate: (details) => setState(() {
            controlStickPosition = calculateControlStickPosition(details.localPosition);
            processCallback(details.localPosition);
          }),
          onPanEnd: (details) => setState(() {
            controlStickPosition = calculateControlStickPosition(center);
            processCallback(center);
          }),
          child: Stack(
            children: [
              Stack(
                children: [
                  Align(
                      alignment: Alignment.topCenter,
                      child: InkResponse(
                          radius: widget.sizeControlStick / 4,
                          splashColor: widget.colorControlStick,
                          onTap: widget.onClickedUp ?? () {},
                          child: Icon(Icons.keyboard_arrow_up, color: widget.colorIcon))),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: InkResponse(
                          radius: widget.sizeControlStick / 4,
                          splashColor: widget.colorControlStick,
                          onTap: widget.onClickedDown ?? () {},
                          child: Icon(Icons.keyboard_arrow_down, color: widget.colorIcon))),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: InkResponse(
                          radius: widget.sizeControlStick / 4,
                          splashColor: widget.colorControlStick,
                          onTap: widget.onClickedLeft ?? () {},
                          child: Icon(Icons.keyboard_arrow_left, color: widget.colorIcon))),
                  Align(
                      alignment: Alignment.centerRight,
                      child: InkResponse(
                          radius: widget.sizeControlStick / 4,
                          splashColor: widget.colorControlStick,
                          onTap: widget.onClickedRight ?? () {},
                          child: Icon(Icons.keyboard_arrow_right, color: widget.colorIcon))),
                ],
              ),
              Positioned(
                top: controlStickPosition.dy,
                left: controlStickPosition.dx,
                child: Container(
                  width: controlStickSize,
                  height: controlStickSize,
                  decoration: BoxDecoration(color: widget.colorControlStick, shape: BoxShape.circle),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
