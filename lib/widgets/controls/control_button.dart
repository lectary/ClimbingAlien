import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ControlButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: 100,
        height: 100,
        child: Material(
          borderRadius: BorderRadius.circular(50),
          color: Colors.grey,
          child: Stack(
            fit: StackFit.loose,
            children: [
              Align(
                  alignment: Alignment.topCenter,
                  child: IconButton(splashRadius: 20, icon: Icon(Icons.keyboard_arrow_up), onPressed: () {})),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: IconButton(splashRadius: 20, icon: Icon(Icons.keyboard_arrow_down), onPressed: () {})),
              Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(splashRadius: 20, icon: Icon(Icons.keyboard_arrow_left), onPressed: () {})),
              Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(splashRadius: 20, icon: Icon(Icons.keyboard_arrow_right), onPressed: () {})),
            ],
          ),
        ),
      ),
    );
  }
}
