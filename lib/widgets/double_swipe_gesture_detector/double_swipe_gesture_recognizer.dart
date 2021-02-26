import 'package:flutter/gestures.dart';

class DoubleSwipeGestureRecognizer extends MultiDragGestureRecognizer {
  final List<PointerDownEvent> events = [];

  @override
  MultiDragPointerState createNewPointerState(PointerDownEvent event) {
    events.add(event);
    return _DoubleSwipePointerState(event.position, onDisposeState: () {
      events.remove(event);
    });
  }

  @override
  String get debugDescription => 'custom double swipe multi drag';
}

typedef OnDisposeState();

class _DoubleSwipePointerState extends MultiDragPointerState {
  final OnDisposeState onDisposeState;

  _DoubleSwipePointerState(Offset initialPosition, {this.onDisposeState})
      : super(initialPosition, PointerDeviceKind.touch);

  @override
  void checkForResolutionAfterMove() {
    if (pendingDelta.dx.abs() > kTouchSlop || pendingDelta.dy.abs() > kTouchSlop) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) {
    starter(initialPosition);
  }

  @override
  void dispose() {
    onDisposeState?.call();
    super.dispose();
  }
}
