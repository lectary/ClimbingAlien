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
  static const _defaultSpeed = 10.0;

  final radius = 20.0;
  final bodyWidth = 50.0;
  final bodyHeight = 80.0;

  Offset _climaxPosition;
  Offset _leftArmOffset;
  Offset _rightArmOffset;
  Offset _leftLegOffset;
  Offset _rightLegOffset;

  Rect _bodyRect;
  Rect _leftArmRect;
  Rect _rightArmRect;
  Rect _leftLegRect;
  Rect _rightLegRect;

  Map<ClimaxLimbEnum, Rect> _climaxLimbs;
  Map<ClimaxLimbEnum, Rect> get climaxLimbs => _climaxLimbs;

  ClimaxLimbEnum _selectedLimb = ClimaxLimbEnum.BODY;
  ClimaxLimbEnum get selectedLimb => _selectedLimb;


  double _degrees = 0.0; // direction, analogues to clock
  double _speed = 0.0;
  double _strength = 0.0;

  ClimaxViewModel() {
    resetClimax();
  }

  /// Updates climax' rectangles data for redrawing.
  _updateClimax() {
    _bodyRect = Rect.fromCenter(center: _climaxPosition, width: bodyWidth, height: bodyHeight);
    _leftArmRect = Rect.fromCircle(center: _climaxPosition + _leftArmOffset, radius: radius);
    _rightArmRect = Rect.fromCircle(center: _climaxPosition + _rightArmOffset, radius: radius);
    _leftLegRect = Rect.fromCircle(center: _climaxPosition + _leftLegOffset, radius: radius);
    _rightLegRect = Rect.fromCircle(center: _climaxPosition + _rightLegOffset, radius: radius);

    _climaxLimbs = HashMap.from({
      ClimaxLimbEnum.BODY: _bodyRect,
      ClimaxLimbEnum.LEFT_ARM: _leftArmRect,
      ClimaxLimbEnum.RIGHT_ARM: _rightArmRect,
      ClimaxLimbEnum.RIGHT_LEG: _rightLegRect,
      ClimaxLimbEnum.LEFT_LEG: _leftLegRect,
    });

    notifyListeners();
  }

  /// Resets the position of climax to an optional offset. Default is [Offset.zero], i.e. left-top screen dorner.
  resetClimax({Offset position = Offset.zero}) {
    _climaxPosition = position;
    _leftArmOffset = Offset(-50, -70);
    _rightArmOffset = Offset(50, -70);
    _leftLegOffset = Offset(-50, 70);
    _rightLegOffset = Offset(50, 70);

    _updateClimax();
  }

  updateClimaxPosition(Offset newPosition) {
    _climaxPosition = newPosition;
    _updateClimax();
  }

  /// Updates the offset of the currently selected limb.
  updateSelectedLimbPosition(Offset newPosition) {
    switch (this._selectedLimb) {
      case ClimaxLimbEnum.BODY:
        _climaxPosition = newPosition;
        break;

      // For arms and legs, calculate the new offset relative to the body
      case ClimaxLimbEnum.LEFT_ARM:
        _leftArmOffset = newPosition - _climaxPosition;
        break;

      case ClimaxLimbEnum.RIGHT_ARM:
        _rightArmOffset = newPosition - _climaxPosition;
        break;

      case ClimaxLimbEnum.RIGHT_LEG:
        _rightLegOffset = newPosition - _climaxPosition;
        break;

      case ClimaxLimbEnum.LEFT_LEG:
        _leftLegOffset = newPosition - _climaxPosition;
        break;
    }

    _updateClimax();
  }

  selectNextLimb() {
    _selectedLimb = ClimaxLimbEnum.values[(_selectedLimb.index + 1) % 5];
    notifyListeners();
  }

  selectLimb(ClimaxLimbEnum limb) {
    this._selectedLimb = limb;
    notifyListeners();
  }

  /// Moving limbs directional. Uses [Direction] to determine direction. Uses [selectedLimb] if [limb] is null.
  moveLimbDirectional(Direction direction, {ClimaxLimbEnum limb, double speed = _defaultSpeed}) {
    updateLimbDirectional(limb ?? this._selectedLimb, direction, speed);
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
        _climaxPosition = _climaxPosition + Offset(moveX, moveY);
        break;

      case ClimaxLimbEnum.LEFT_ARM:
        _leftArmOffset = _leftArmOffset + Offset(moveX, moveY);
        break;

      case ClimaxLimbEnum.RIGHT_ARM:
        _rightArmOffset = _rightArmOffset + Offset(moveX, moveY);
        break;

      case ClimaxLimbEnum.LEFT_LEG:
        _leftLegOffset = _leftLegOffset + Offset(moveX, moveY);
        break;

      case ClimaxLimbEnum.RIGHT_LEG:
        _rightLegOffset = _rightLegOffset + Offset(moveX, moveY);
        break;
    }

    _updateClimax();
  }

  /// Moving limbs freely by a joystick. Sets the parameter for calculating the position.
  /// Uses [degrees] to calculate the direction and [strength] to determine
  /// how hard the joystick is pulled to the outer border, which influences the speed. Asserts that [strength] is
  /// between 0 and 1.
  moveLimbFree(double degrees, double strength, {ClimaxLimbEnum limb, double speed = _defaultSpeed}) {
    if (limb != null) this._selectedLimb = limb;
    this._speed = speed;
    this._degrees = degrees;
    this._strength = strength;
  }

  /// Calculates the position of Climax' limbs based on the current movement values, set by [moveLimbFree].
  updateLimbFree() {
    double moveX = 0;
    double moveY = 0;

    var x = this._strength * this._speed * _math.cos(this._degrees * _math.pi / 180);
    var y = this._strength * this._speed * _math.sin(this._degrees * _math.pi / 180);

    // Corrections needed because the origin is the top-left corner and (x,y) uses an origin in the center.
    moveX = y;
    moveY = -x;

    switch (this.selectedLimb) {
      case ClimaxLimbEnum.BODY:
        _climaxPosition = _climaxPosition + Offset(moveX, moveY);
        break;

      case ClimaxLimbEnum.LEFT_ARM:
        _leftArmOffset = _leftArmOffset + Offset(moveX, moveY);
        break;

      case ClimaxLimbEnum.RIGHT_ARM:
        _rightArmOffset = _rightArmOffset + Offset(moveX, moveY);
        break;

      case ClimaxLimbEnum.LEFT_LEG:
        _leftLegOffset = _leftLegOffset + Offset(moveX, moveY);
        break;

      case ClimaxLimbEnum.RIGHT_LEG:
        _rightLegOffset = _rightLegOffset + Offset(moveX, moveY);
        break;
    }

    _updateClimax();
  }
}
