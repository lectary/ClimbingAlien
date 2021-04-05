import 'dart:collection';
import 'dart:math' as _math;

import 'package:climbing_alien/data/entity/grasp.dart';
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

  late Offset _leftArmOffset;
  late Offset _rightArmOffset;
  late Offset _leftLegOffset;
  late Offset _rightLegOffset;

  Rect? _bodyRect;
  Rect? _leftArmRect;
  Rect? _rightArmRect;
  Rect? _leftLegRect;
  Rect? _rightLegRect;

  Map<ClimaxLimbEnum, Rect>? _climaxLimbs;
  Map<ClimaxLimbEnum, Rect>? get climaxLimbs => _climaxLimbs;

  ClimaxLimbEnum? _selectedLimb;
  ClimaxLimbEnum? get selectedLimb => _selectedLimb;

  double _degrees = 0.0; // direction, analogues to clock
  double _speed = _defaultSpeed;
  double _strength = 0.0;

  bool transformAll = false;

  // scale
  double baseScaleBackground = 1.0;
  double scaleBackground = 1.0;

  double baseScaleAll = 1.0;
  double scaleAll = 1.0;

  // translate
  Offset lastTranslateBackground = Offset(1.0, 1.0);
  Offset deltaTranslateBackground = Offset(1.0, 1.0);

  Offset lastTranslateAll = Offset(1.0, 1.0);
  Offset deltaTranslateAll = Offset(1.0, 1.0);

  bool tapOn = false;
  bool climaxMoved = false;
  Function? updateCallback;
  // TODO remove?
  int order = 0;

  Size _size;

  ClimaxViewModel({required Size size}) : _size = size {
    resetClimax();
  }

  Grasp getCurrentPosition() {
    Grasp newGrasp = Grasp(
      leftArm: _leftArmOffset,
      rightArm: _rightArmOffset,
      leftLeg: _leftLegOffset,
      rightLeg: _rightLegOffset, routeId: 0,
    );
    return newGrasp;
  }

  setupByGrasp(Grasp grasp) {
    _leftArmOffset = grasp.leftArm;
    _rightArmOffset = grasp.rightArm;
    _leftLegOffset = grasp.leftLeg;
    _rightLegOffset = grasp.rightLeg;
  }

  /// Computing the four sides/points of the AABB (axis aligned bounding box) of climax
  _computeClimaxCenter() {
    double minXArm = _math.min(_leftArmOffset.dx, _rightArmOffset.dx);
    double minXLeg = _math.min(_leftLegOffset.dx, _rightLegOffset.dx);
    double minX = _math.min(minXArm, minXLeg);

    double minYArm = _math.min(_leftArmOffset.dy, _rightArmOffset.dy);
    double minYLeg = _math.min(_leftLegOffset.dy, _rightLegOffset.dy);
    double minY = _math.min(minYArm, minYLeg);

    double maxXArm = _math.max(_leftArmOffset.dx, _rightArmOffset.dx);
    double maxXLeg = _math.max(_leftLegOffset.dx, _rightLegOffset.dx);
    double maxX = _math.max(maxXArm, maxXLeg);

    double maxYArm = _math.max(_leftArmOffset.dy, _rightArmOffset.dy);
    double maxYLeg = _math.max(_leftLegOffset.dy, _rightLegOffset.dy);
    double maxY = _math.max(maxYArm, maxYLeg);

    return Rect.fromLTRB(minX, minY, maxX, maxY).center;
  }

  bool isTranslating = false;

  _refreshFollowerCamera() {
    Offset climaxCenter = _computeClimaxCenter();
    Offset screenCenter = Offset(_size.width / 2, (_size.height - kToolbarHeight) / 2);

    deltaTranslateAll = climaxCenter - screenCenter;
  }

  /// Updates climax' rectangles data for redrawing.
  _updateClimax() {
    if (!isTranslating) {
      _refreshFollowerCamera();
    }

    _bodyRect = Rect.fromCenter(center: _computeClimaxCenter(), width: bodyWidth, height: bodyHeight);
    _leftArmRect = Rect.fromCircle(center: _leftArmOffset, radius: radius);
    _rightArmRect = Rect.fromCircle(center: _rightArmOffset, radius: radius);
    _leftLegRect = Rect.fromCircle(center: _leftLegOffset, radius: radius);
    _rightLegRect = Rect.fromCircle(center: _rightLegOffset, radius: radius);

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
  resetClimax({Offset position = const Offset(75,100)}) {
    _leftArmOffset = position + Offset(-50, -75);
    _rightArmOffset = position + Offset(50, -75);
    _leftLegOffset = position + Offset(-50, 75);
    _rightLegOffset = position + Offset(50, 75);

    scaleAll = 1.0;
    deltaTranslateAll = Offset(1.0, 1.0);

    _updateClimax();
  }

  /// Updates the offset of the currently selected limb.
  updateSelectedLimbPosition(Offset newPosition) {
    switch (this._selectedLimb) {
      case ClimaxLimbEnum.BODY:
        Offset diff = _computeClimaxCenter() - newPosition;
        _leftArmOffset = _leftArmOffset - diff;
        _rightArmOffset = _rightArmOffset - diff;
        _leftLegOffset = _leftLegOffset - diff;
        _rightLegOffset = _rightLegOffset - diff;
        break;

      // For arms and legs, calculate the new offset relative to the body
      // Add translation offset to newPosition to get the local, tapped position and not the translated one.
      // Divide through scale parameter, to get the local, tapped position and not the scaled one.
      case ClimaxLimbEnum.LEFT_ARM:
        _leftArmOffset = (newPosition + deltaTranslateAll) / scaleAll;
        break;

      case ClimaxLimbEnum.RIGHT_ARM:
        _rightArmOffset = (newPosition + deltaTranslateAll) / scaleAll;
        break;

      case ClimaxLimbEnum.RIGHT_LEG:
        _rightLegOffset = (newPosition + deltaTranslateAll) / scaleAll;
        break;

      case ClimaxLimbEnum.LEFT_LEG:
        _leftLegOffset = (newPosition + deltaTranslateAll) / scaleAll;
        break;
    }

    climaxMoved = true;
    // Update grasp
    updateCallback?.call();

    _updateClimax();
  }

  selectNextLimb() {
    _selectedLimb = ClimaxLimbEnum.values[(_selectedLimb?.index ?? 1  + 1) % 5];
    notifyListeners();
  }

  selectLimb(ClimaxLimbEnum limb) {
    this._selectedLimb = limb;
    notifyListeners();
  }

  updateSpeed(double speed) {
    this._speed = speed;
    notifyListeners();
  }

  /// Moving limbs directional. Uses [Direction] to determine direction. Uses [selectedLimb] if [limb] is null.
  moveLimbDirectional(Direction direction, {ClimaxLimbEnum? limb}) {
    if (limb == null && _selectedLimb == null) {
      return;
    } else {
      updateLimbDirectional(limb ?? _selectedLimb!, direction);
    }
  }

  updateLimbDirectional(ClimaxLimbEnum limb, Direction direction) {
    double moveX = 0;
    double moveY = 0;

    double speed = this._speed;

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
        _leftArmOffset = _leftArmOffset + Offset(moveX, moveY);
        _rightArmOffset = _rightArmOffset + Offset(moveX, moveY);
        _leftLegOffset = _leftLegOffset + Offset(moveX, moveY);
        _rightLegOffset = _rightLegOffset + Offset(moveX, moveY);
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

    climaxMoved = true;
    // Update grasp
    updateCallback?.call();

    _updateClimax();
  }

  /// Moving limbs freely by a joystick. Sets the parameter for calculating the position.
  /// Uses [degrees] to calculate the direction and [strength] to determine
  /// how hard the joystick is pulled to the outer border, which influences the speed. Asserts that [strength] is
  /// between 0 and 1.
  /// Works together with [updateLimbFree], which is called continuously by the climax widget, and
  /// moves climax based on the parameter passed to this function [moveLimbFree].
  moveLimbFree(double degrees, double strength, {ClimaxLimbEnum? limb}) {
    if (limb != null) this._selectedLimb = limb;
    this._degrees = degrees;
    this._strength = strength;

    climaxMoved = true;

    // When climax was moved but strength is zero, indicating the joystick was left, update grasp
    if (climaxMoved && strength == 0) {
      updateCallback?.call();
    }
  }

  /// Calculates the position of Climax' limbs based on the current movement values, set by [moveLimbFree].
  /// This function is called
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
        _leftArmOffset = _leftArmOffset + Offset(moveX, moveY);
        _rightArmOffset = _rightArmOffset + Offset(moveX, moveY);
        _leftLegOffset = _leftLegOffset + Offset(moveX, moveY);
        _rightLegOffset = _rightLegOffset + Offset(moveX, moveY);
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

  void unselectAll() {
    _selectedLimb = null;
  }
}
