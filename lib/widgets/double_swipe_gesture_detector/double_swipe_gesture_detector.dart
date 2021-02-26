import 'package:climbing_alien/widgets/double_swipe_gesture_detector/double_swipe_drag.dart';
import 'package:climbing_alien/widgets/double_swipe_gesture_detector/double_swipe_gesture_recognizer.dart';
import 'package:flutter/material.dart';

/// Custom Gesture Detector using [RawGestureDetector] and custom [DoubleSwipeGestureRecognizer] for
/// allowing double-finger swipe gestures.
class DoubleSwipeGestureDetector extends StatelessWidget {
  final OnUpdate onUpdate;
  final Widget child;

  DoubleSwipeGestureDetector({this.onUpdate, this.child});

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        DoubleSwipeGestureRecognizer: GestureRecognizerFactoryWithHandlers<DoubleSwipeGestureRecognizer>(
            () => DoubleSwipeGestureRecognizer(), (DoubleSwipeGestureRecognizer instance) {
          instance.onStart = (_) {
            return new DoubleSwipeDrag(events: instance.events, onUpdate: onUpdate);
          };
        }),
      },
      child: child,
    );
  }
}
