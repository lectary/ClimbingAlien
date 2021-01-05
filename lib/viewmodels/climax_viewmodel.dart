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

  selectLimb(ClimaxLimbEnum limb) {}

  /// Moving limbs directional. Uses [Direction] to determine direction.
  moveSelectedLimb(Direction direction, {double speed = defaultSpeed}) {
    updateLimbDirectional(this.selectedLimb, direction, speed);
  }

  moveLimb(ClimaxLimbEnum limb, Direction direction, {double speed = defaultSpeed}) {
    updateLimbDirectional(limb, direction, speed);
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

  /// Moving limbs freely by a joystick. Using degrees to calculate direction and optional strength to
  /// how hard the joystick is pulled to one side.
  moveSelectedLimbFree(double degrees, double strength, {double speed = defaultSpeed}) {
    updateLimbFree(this.selectedLimb, degrees, strength, speed);
  }

  moveLimbFree(ClimaxLimbEnum limb, double degrees, double strength, {double speed = defaultSpeed}) {
    updateLimbFree(limb, degrees, strength, speed);
  }

  updateLimbFree(ClimaxLimbEnum limb, double degrees, double acceleration, double speed) {
    double moveX = 0;
    double moveY = 0;

    moveX = acceleration * speed * _math.cos(degrees * _math.pi / 180);
    moveY = acceleration * speed * _math.sin(degrees * _math.pi / 180);

    // Fixing directions, needed because the origin is the top-left corner.
    moveX = -moveY;
    moveY = moveX;

    print("MoveX: $moveX");
    print("MoveY: $moveY");

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
}
