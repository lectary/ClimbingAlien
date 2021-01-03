import 'dart:math' as _math;

import 'package:flutter/material.dart';

class Joystick2 extends StatefulWidget {
  final double size = 100;

  @override
  _Joystick2State createState() => _Joystick2State();
}

class _Joystick2State extends State<Joystick2> {
  Offset defaultPosition;
  Offset stickPosition;

  @override
  void initState() {
    super.initState();
    defaultPosition = Offset(widget.size / 4, widget.size / 4);
    stickPosition = defaultPosition;
  }

  void updatePosition(Offset offset) {
    setState(() {
      // position
      stickPosition = Offset(offset.dx, offset.dy);
      print(stickPosition);

      // Callback info
    });
  }

  void resetStick() {
    setState(() {
      stickPosition = defaultPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
        color: Colors.grey,
        child: Stack(
          children: [
            Align(alignment: Alignment.topCenter, child: Icon(Icons.keyboard_arrow_up)),
            Align(alignment: Alignment.bottomCenter, child: Icon(Icons.keyboard_arrow_down)),
            Align(alignment: Alignment.centerLeft, child: Icon(Icons.keyboard_arrow_left)),
            Align(alignment: Alignment.centerRight, child: Icon(Icons.keyboard_arrow_right)),
            Positioned(
              top: stickPosition.dy,
              left: stickPosition.dx,
              child: GestureDetector(
                onPanUpdate: (details) {
                  updatePosition(details.localPosition);
                },
                onPanEnd: (details) => resetStick(),
                child: Opacity(
                  opacity: 1,
                  child: Container(
                    width: widget.size / 2,
                    height: widget.size / 2,
                    decoration: BoxDecoration(color: Colors.grey[600], shape: BoxShape.circle),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
