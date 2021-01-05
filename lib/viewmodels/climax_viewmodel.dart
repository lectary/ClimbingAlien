import 'dart:collection';
import 'dart:math' as _math;

import 'package:flutter/material.dart';

enum ClimaxLimbEnum {
  BODY,
  LEFT_ARM,
  RIGHT_ARM,
  RIGHT_LEG,
  LEFT_LEG,
}

enum Direction {
  UP,
  DOWN,
  LEFT,
  RIGHT,
}

class ClimaxViewModel extends ChangeNotifier {
  static const defaultSpeed = 10.0;

  final radius = 20.0;
  final bodyWidth = 50.0;
  final bodyHeight = 80.0;

  Offset climaxPosition;
  Offset leftArmOffset;
  Offset rightArmOffset;
  Offset leftLegOffset;
  Offset rightLegOffset;

  Rect _bodyRect;
  Rect _leftArmRect;
  Rect _rightArmRect;
  Rect _leftLegRect;
  Rect _rightLegRect;

  Map<ClimaxLimbEnum, Rect> climaxLimbs;
  ClimaxLimbEnum selectedLimb = ClimaxLimbEnum.BODY;

  double degrees = 0.0; // direction, analogues to clock
  double speed = 0.0;
  double acceleration = 0.0;

  ClimaxViewModel() {
    resetClimax();
  }

  updateClimax() {
    _bodyRect = Rect.fromCenter(center: climaxPosition, width: bodyWidth, height: bodyHeight);
    _leftArmRect = Rect.fromCircle(center: climaxPosition + leftArmOffset, radius: radius);
    _rightArmRect = Rect.fromCircle(center: climaxPosition + rightArmOffset, radius: radius);
    _leftLegRect = Rect.fromCircle(center: climaxPosition + leftLegOffset, radius: radius);
    _rightLegRect = Rect.fromCircle(center: climaxPosition + rightLegOffset, radius: radius);

    climaxLimbs = HashMap.from({
      ClimaxLimbEnum.BODY: _bodyRect,
      ClimaxLimbEnum.LEFT_ARM: _leftArmRect,
      ClimaxLimbEnum.RIGHT_ARM: _rightArmRect,
      ClimaxLimbEnum.RIGHT_LEG: _rightLegRect,
      ClimaxLimbEnum.LEFT_LEG: _leftLegRect,
    });

    notifyListeners();
  }

  resetClimax({Offset position = Offset.zero}) {
    climaxPosition = position;
    leftArmOffset = Offset(-50, -70);
    rightArmOffset = Offset(50, -70);
    leftLegOffset = Offset(-50, 70);
    rightLegOffset = Offset(50, 70);

    updateClimax();
  }

  updateClimaxPosition(Offset newPosition) {
    climaxPosition = newPosition;
    print(newPosition);
    updateClimax();
  }

  selectNextLimb() {
    selectedLimb = ClimaxLimbEnum.values[(selectedLimb.index + 1) % 5];
    notifyListeners();
  }

  selectLimb(ClimaxLimbEnum limb) {
    this.selectedLimb = limb;
    notifyListeners();
  }

  /// Moving limbs directional. Uses [Direction] to determine direction. Uses [selectedLimb] if [limb] is null.
  moveLimbDirectional(Direction direction, {ClimaxLimbEnum limb, double speed = defaultSpeed}) {
    updateLimbDirectional(limb ?? this.selectedLimb, direction, speed);
  }

  updateLimbDirectional(ClimaxLimbEnum limb, Direction direction, double speed) {
    double moveX = 0;
    double moveY = 0;

    switch (direction) {
      case Direction.UP:
        moveY = -speed;
        break;

      case Direction.DOWN:
        moveY = speed;
        break;

      case Direction.LEFT:
        moveX = -speed;
        break;

      case Direction.RIGHT:
        moveX = speed;
        break;
    }

    switch (limb) {
      case ClimaxLimbEnum.BODY:
        climaxPosition = climaxPosition + Offset(moveX, moveY);
        break;

      case ClimaxLimbEnum.LEFT_ARM:
        leftArmOffset = leftArmOffset + Offset(moveX, moveY);
        break;

      case ClimaxLimbEnum.RIGHT_ARM:
        rightArmOffset = rightArmOffset + Offset(moveX, moveY);
        break;

      case ClimaxLimbEnum.LEFT_LEG:
        leftLegOffset = leftLegOffset + Offset(moveX, moveY);
        break;

      case ClimaxLimbEnum.RIGHT_LEG:
        rightLegOffset = rightLegOffset + Offset(moveX, moveY);
        break;
    }

    updateClimax();
  }

  /// Moving limbs freely by a joystick. Sets the parameter for calculating the position.
  /// Uses [degrees] to calculate the direction and [strength] to determine
  /// how hard the joystick is pulled to the outer border, which influences the speed. Asserts that [strength] is
  /// between 0 and 1.
  moveLimbFree(double degrees, double strength, {ClimaxLimbEnum limb, double speed = defaultSpeed}) {
    if (limb != null) this.selectedLimb = limb;
    this.speed = speed;
    this.degrees = degrees;
    this.acceleration = strength;
  }

  /// Calculates the position of Climax' limbs based on the current movement values, set by [moveLimbFree].
  updateLimbFree() {
    double moveX = 0;
    double moveY = 0;

    var x = this.acceleration * defaultSpeed * _math.cos(this.degrees * _math.pi / 180);
    var y = this.acceleration * defaultSpeed * _math.sin(this.degrees * _math.pi / 180);

    // Corrections needed because the origin is the top-left corner and (x,y) uses an origin in the center.
    moveX = y;
    moveY = -x;

    switch (this.selectedLimb) {
      case ClimaxLimbEnum.BODY:
        climaxPosition = climaxPosition + Offset(moveX, moveY);
        break;

      case ClimaxLimbEnum.LEFT_ARM:
        leftArmOffset = leftArmOffset + Offset(moveX, moveY);
        break;

      case ClimaxLimbEnum.RIGHT_ARM:
        rightArmOffset = rightArmOffset + Offset(moveX, moveY);
        break;

      case ClimaxLimbEnum.LEFT_LEG:
        leftLegOffset = leftLegOffset + Offset(moveX, moveY);
        break;

      case ClimaxLimbEnum.RIGHT_LEG:
        rightLegOffset = rightLegOffset + Offset(moveX, moveY);
        break;
    }

    updateClimax();
  }
}
