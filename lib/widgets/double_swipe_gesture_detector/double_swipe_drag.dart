import 'package:flutter/gestures.dart';

typedef OnUpdate(DragUpdateDetails details);

/// Drag Event for retrieving updates about the Drag Status.
/// Updates are only triggered, when two pointers are on the screen.
class DoubleSwipeDrag extends Drag {
  final List<PointerDownEvent>? events;
  final OnUpdate? onUpdate;

  DoubleSwipeDrag({this.events, this.onUpdate});

  @override
  void update(DragUpdateDetails details) {
    super.update(details);
    if (events!.length == 2) {
      onUpdate?.call(DragUpdateDetails(
        sourceTimeStamp: details.sourceTimeStamp,
        delta: Offset(details.delta.dx, details.delta.dy),
        primaryDelta: details.primaryDelta,
        globalPosition: details.globalPosition,
        localPosition: details.localPosition,
      ));
    }
  }

  @override
  void end(DragEndDetails details) {
    super.end(details);
  }
}
