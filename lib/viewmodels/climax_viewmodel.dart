import 'dart:collection';

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

  resetClimax() {
    climaxPosition = Offset.zero;
    leftArmOffset = Offset(-50, -70);
    rightArmOffset = Offset(50, -70);
    leftLegOffset = Offset(-50, 70);
    rightLegOffset = Offset(50, 70);

    updateClimax();
  }

  updateClimaxPosition(Offset newPosition) {
    climaxPosition = newPosition;
    updateClimax();
  }

  selectNextLimb() {
    selectedLimb = ClimaxLimbEnum.values[(selectedLimb.index + 1) % 5];
    notifyListeners();
  }

  selectLimb(ClimaxLimbEnum limb) {}

  moveSelectedLimb(Direction direction) {
    updateLimb(this.selectedLimb, direction);
  }

  moveLimb(ClimaxLimbEnum limb, Direction direction) {
    updateLimb(limb, direction);
  }

  updateLimb(ClimaxLimbEnum limb, Direction direction) {
    double moveX = 0;
    double moveY = 0;

    switch (direction) {
      case Direction.UP:
        moveY = 10;
        break;

      case Direction.DOWN:
        moveY = -10;
        break;

      case Direction.LEFT:
        moveX = -10;
        break;

      case Direction.RIGHT:
        moveX = 10;
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
}
