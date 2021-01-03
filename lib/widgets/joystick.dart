import 'package:flutter/material.dart';

class Joystick extends StatefulWidget {
  final ValueChanged<Offset> valueChanged;

  Joystick({this.valueChanged});

  @override
  _JoystickState createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  static final Offset defaultPosition = const Offset(0.5, 0.5);
  ValueNotifier<Offset> valueListener = ValueNotifier(defaultPosition);

  @override
  void initState() {
    valueListener.addListener(notifyParent);
    super.initState();
  }

  notifyParent() {
    print(valueListener.value);
    if (widget.valueChanged != null) {
      widget.valueChanged(valueListener.value);
    }
  }

  @override
  void dispose() {
    valueListener.removeListener(notifyParent);
    super.dispose();
  }

  void resetStick() {
    valueListener.value = defaultPosition;
  }

  @override
  Widget build(BuildContext context) {
    final Widget stick = Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(color: Colors.grey[600], shape: BoxShape.circle),
    );
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: 100,
        height: 100,
        child: Material(
          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(50.0) ),
          color: Colors.grey,
          child: Stack(
            children: [
              Align(alignment: Alignment.topCenter, child: Icon(Icons.keyboard_arrow_up)),
              Align(alignment: Alignment.bottomCenter, child: Icon(Icons.keyboard_arrow_down)),
              Align(alignment: Alignment.centerLeft, child: Icon(Icons.keyboard_arrow_left)),
              Align(alignment: Alignment.centerRight, child: Icon(Icons.keyboard_arrow_right)),
              GestureDetector(
                onPanUpdate: (details) {
                  Offset newOffset = valueListener.value +
                      Offset((details.delta.dx / context.size.width), (details.delta.dy / context.size.height));
                  valueListener.value = Offset(newOffset.dx.clamp(.0, 1.0), newOffset.dy.clamp(.0, 1.0));
                },
                onPanEnd: (details) => resetStick(),
                child: AnimatedBuilder(
                  animation: valueListener,
                  builder: (context, child) {
                    return Align(
                      /// Multiplying value with 2 minus 1 for a projection into the range [-1, 1].
                      alignment: Alignment(valueListener.value.dx * 2 - 1, valueListener.value.dy * 2 - 1),
                      child: child,
                    );
                  },
                  child: stick,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
