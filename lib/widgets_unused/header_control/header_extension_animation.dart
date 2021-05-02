import 'package:flutter/material.dart';

/// An extension area for the header control.
/// Additional features can be displayed via an Slide in like Animation, done via [SizeTransition].
class HeaderExtensionAnimation extends StatefulWidget {
  final List<Widget>? children;
  final Color? buttonColor;

  HeaderExtensionAnimation({this.children, this.buttonColor});

  @override
  _HeaderExtensionAnimationState createState() => _HeaderExtensionAnimationState();
}

class _HeaderExtensionAnimationState extends State<HeaderExtensionAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _extensionEnabled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
    _extensionEnabled ? _animationController.forward() : _animationController.reverse();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          child: ClipRect(
            child: Align(
              widthFactor: 0.5,
              alignment: Alignment.center,
              child: IconButton(
                  padding: EdgeInsets.all(0.0),
                  iconSize: 32,
                  icon: _extensionEnabled
                      ? Icon(
                          Icons.keyboard_arrow_right,
                          color: widget.buttonColor,
                        )
                      : Icon(Icons.keyboard_arrow_left, color: widget.buttonColor),
                  onPressed: () {
                    setState(() {
                      if (_extensionEnabled) {
                        _animationController.reverse();
                        _extensionEnabled = false;
                      } else {
                        _animationController.forward();
                        _extensionEnabled = true;
                      }
                    });
                  }),
            ),
          ),
        ),
        SizeTransition(
          axis: Axis.horizontal,
          axisAlignment: 0,
          sizeFactor: _animation,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...widget.children!,
            ],
          ),
        )
      ],
    );
  }
}
