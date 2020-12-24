import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ControlButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        Align(
            alignment: Alignment.topCenter,
            child: IconButton(
                splashRadius: 20,
                icon: Icon(Icons.keyboard_arrow_up), onPressed: () {})),
        Align(
            alignment: Alignment.bottomCenter,
            child: IconButton(
                splashRadius: 20,
                icon: Icon(Icons.keyboard_arrow_down), onPressed: () {})),
        Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
                splashRadius: 20,
                icon: Icon(Icons.keyboard_arrow_left), onPressed: () {})),
        Align(
            alignment: Alignment.centerRight,
            child: IconButton(
                splashRadius: 20,
                icon: Icon(Icons.keyboard_arrow_right), onPressed: () {})),
      ],
    );
  }
}
