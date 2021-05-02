import 'dart:collection';
import 'dart:math' as _math;

import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/services/shared_prefs_service.dart';
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

  Map<ClimaxLimbEnum, Rect>? _previousClimaxLimbs;
  Map<ClimaxLimbEnum, Rect>? get previousClimaxLimbs => _previousClimaxLimbs;

  double _degrees = 0.0; // direction, analogues to clock
  double _speed = _defaultSpeed;
  double _strength = 0.0;

  bool transformAll = false;

  bool isTranslating = false;
  bool isScaling = false;

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


  /// Colors

  Color _climaxMainColor = SharedPrefsService.DEFAULT_CLIMAX_COLOR;
  Color get climaxMainColor => _climaxMainColor;
  set climaxMainColor(Color climaxMainColor) {
    _climaxMainColor = climaxMainColor;
    SharedPrefsService.saveClimaxColor(climaxMainColor);
  }

  Color _climaxGhostingColor = SharedPrefsService.DEFAULT_GHOSTING_COLOR;
  Color get climaxGhostingColor => _climaxGhostingColor;
  set climaxGhostingColor(Color climaxGhostingColor) {
    _climaxGhostingColor = climaxGhostingColor;
    SharedPrefsService.saveGhostingColor(climaxGhostingColor);
  }

  Color _climaxSelectionColor = SharedPrefsService.DEFAULT_SELECTION_COLOR;
  Color get climaxSelectionColor => _climaxSelectionColor;
  set climaxSelectionColor(Color climaxSelectionColor) {
    _climaxSelectionColor = climaxSelectionColor;
    SharedPrefsService.saveSelectionColor(climaxSelectionColor);
  }

  ClimaxViewModel({required Size size}) : _size = size {
    resetClimax();
    _setupColors();
  }

  void _setupColors() async {
    _climaxMainColor = await SharedPrefsService.getClimaxColor();
    _climaxGhostingColor = await SharedPrefsService.getGhostingColor();
    _climaxSelectionColor = await SharedPrefsService.getSelectionColor();
    notifyListeners();
  }

  void deselectLimb() {
    _selectedLimb = null;
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

  void updateGhost({Grasp? previousGrasp}) {
    if (previousGrasp != null) {
      _previousClimaxLimbs = HashMap.from({
        ClimaxLimbEnum.BODY: Rect.fromCircle(center: Offset.zero, radius: 0),
        ClimaxLimbEnum.LEFT_ARM: Rect.fromCircle(center: previousGrasp.leftArm, radius: radius),
        ClimaxLimbEnum.RIGHT_ARM: Rect.fromCircle(center: previousGrasp.rightArm, radius: radius),
        ClimaxLimbEnum.RIGHT_LEG: Rect.fromCircle(center: previousGrasp.rightLeg, radius: radius),
        ClimaxLimbEnum.LEFT_LEG: Rect.fromCircle(center: previousGrasp.leftLeg, radius: radius),
      });
    } else {
      _previousClimaxLimbs = HashMap.from({
        ClimaxLimbEnum.BODY: _bodyRect,
        ClimaxLimbEnum.LEFT_ARM: _leftArmRect,
        ClimaxLimbEnum.RIGHT_ARM: _rightArmRect,
        ClimaxLimbEnum.RIGHT_LEG: _rightLegRect,
        ClimaxLimbEnum.LEFT_LEG: _leftLegRect,
      });
    }
  }

  setupByGrasp(Grasp grasp) {
    if (grasp.order! > 2) {
      updateGhost();
    }

    _leftArmOffset = grasp.leftArm;
    _rightArmOffset = grasp.rightArm;
    _leftLegOffset = grasp.leftLeg;
    _rightLegOffset = grasp.rightLeg;

    // Deselect current limb
    deselectLimb();
  }

  /// ****************************************************************************************************************
  /// Logic for followerCamera and automatic scaling
  /// ****************************************************************************************************************
  Offset climaxCenter = Offset.zero;
  Offset screenCenter = Offset.zero;

  _refreshFollowerCamera() {
    climaxCenter = _computeClimaxCenter();
    screenCenter = Offset(_size.width / 2, (_size.height - kToolbarHeight) / 2);

    deltaTranslateAll = climaxCenter - screenCenter;

    // Check whether limbs exceed screen border and adjust scale
    scaleAll = _calculateScaleBasedOnClimaxPosition(scaleAll, climaxCenter, screenCenter);
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

  /// Calculates the scale value based on the current positions of climax' limbs.
  /// Uses [threshold] as percentage of the screen distance to the borders at which scaling will be triggered.
  /// [scaleAccuracy] determines the percentage of the screen size as accuracy at which the scaling will be increased and decreased.
  /// The lower end of scaling (zooming in) is limited by [defaultScale].
  double _calculateScaleBasedOnClimaxPosition(double scale, Offset climaxCenter, Offset screenCenter) {
    double scaleAll = scale;

    double threshold = 0.10;
    double scaleAccuracy = 0.025;
    double defaultScale = 1;

    Offset thresholdOffset = Offset(threshold * _size.width, threshold * (_size.height - kToolbarHeight));
    Offset halfScreenSize = screenCenter;

    //--------------------------------------------------------------------------------------
    // Check whether the limbs are running under the threshold to increase scale (zoom out)
    //--------------------------------------------------------------------------------------

    // Calculate the relative border offsets based on the current climaxCenter
    Offset minThreshold = climaxCenter - (halfScreenSize - thresholdOffset) / scaleAll;
    Offset maxThreshold = climaxCenter + (halfScreenSize + thresholdOffset) / scaleAll;

    bool zoomOut = _checkZoomOut(minThreshold, maxThreshold);

    while (zoomOut) {
      scaleAll = scaleAll - scaleAccuracy;

      minThreshold = climaxCenter - (halfScreenSize - thresholdOffset) / scaleAll;
      maxThreshold = climaxCenter + (halfScreenSize + thresholdOffset) / scaleAll;

      zoomOut = _checkZoomOut(minThreshold, maxThreshold);
    }

    //--------------------------------------------------------------------------------------
    // Check whether the limbs are running over the threshold to decrease scale (zoom in)
    //--------------------------------------------------------------------------------------

    // Calculate the relative border offsets based on the current climaxCenter
    Offset minMaxThreshold = climaxCenter - (halfScreenSize - thresholdOffset - thresholdOffset) / scaleAll;
    Offset maxMinThreshold = climaxCenter + (halfScreenSize + thresholdOffset + thresholdOffset) / scaleAll;

    bool zoomIn = _checkZoomIn(minMaxThreshold, maxMinThreshold);

    while (zoomIn) {
      if (scaleAll + scaleAccuracy >= defaultScale) {
        scaleAll = defaultScale;
        break;
      } else {
        scaleAll = scaleAll + scaleAccuracy;
      }

      minMaxThreshold = climaxCenter - (halfScreenSize - thresholdOffset - thresholdOffset) / scaleAll;
      maxMinThreshold = climaxCenter + (halfScreenSize + thresholdOffset + thresholdOffset) / scaleAll;

      zoomIn = _checkZoomIn(minMaxThreshold, maxMinThreshold);
    }

    return scaleAll;
  }


  /// Checks whether one of climax's limbs is lower than [minThreshold] or bigger than [maxThreshold].
  bool _checkZoomOut(Offset minThreshold, Offset maxThreshold) {
    bool leftArmOutOfBorder = _leftArmOffset.dx <= minThreshold.dx ||
        _leftArmOffset.dy <= minThreshold.dy ||
        _leftArmOffset.dx >= maxThreshold.dx ||
        _leftArmOffset.dy >= maxThreshold.dy;
    bool rightArmOutOfBorder = _rightArmOffset.dx <= minThreshold.dx ||
        _rightArmOffset.dy <= minThreshold.dy ||
        _rightArmOffset.dx >= maxThreshold.dx ||
        _rightArmOffset.dy >= maxThreshold.dy;
    bool leftLegOutOfBorder = _leftLegOffset.dx <= minThreshold.dx ||
        _leftLegOffset.dy <= minThreshold.dy ||
        _leftLegOffset.dx >= maxThreshold.dx ||
        _leftLegOffset.dy >= maxThreshold.dy;
    bool rightLegOutOfBorder = _rightLegOffset.dx <= minThreshold.dx ||
        _rightLegOffset.dy <= minThreshold.dy ||
        _rightLegOffset.dx >= maxThreshold.dx ||
        _rightLegOffset.dy >= maxThreshold.dy;

    return leftArmOutOfBorder || rightArmOutOfBorder || leftLegOutOfBorder || rightLegOutOfBorder;
  }

  /// Checks whether all of climax' limbs are bigger than [minMaxThreshold] and lower than [maxMinThreshold].
  bool _checkZoomIn(Offset minMaxThreshold, Offset maxMinThreshold) {
    bool leftArmInOfBorder = _leftArmOffset.dx <= maxMinThreshold.dx &&
        _leftArmOffset.dy <= maxMinThreshold.dy &&
        _leftArmOffset.dx >= minMaxThreshold.dx &&
        _leftArmOffset.dy >= minMaxThreshold.dy;
    bool rightArmInOfBorder = _rightArmOffset.dx <= maxMinThreshold.dx &&
        _rightArmOffset.dy <= maxMinThreshold.dy &&
        _rightArmOffset.dx >= minMaxThreshold.dx &&
        _rightArmOffset.dy >= minMaxThreshold.dy;
    bool leftLegInOfBorder = _leftLegOffset.dx <= maxMinThreshold.dx &&
        _leftLegOffset.dy <= maxMinThreshold.dy &&
        _leftLegOffset.dx >= minMaxThreshold.dx &&
        _leftLegOffset.dy >= minMaxThreshold.dy;
    bool rightLegInOfBorder = _rightLegOffset.dx <= maxMinThreshold.dx &&
        _rightLegOffset.dy <= maxMinThreshold.dy &&
        _rightLegOffset.dx >= minMaxThreshold.dx &&
        _rightLegOffset.dy >= minMaxThreshold.dy;

    return leftArmInOfBorder && rightArmInOfBorder && leftLegInOfBorder && rightLegInOfBorder;
  }

  /// ****************************************************************************************************************
  /// ****************************************************************************************************************

  /// Updates climax' rectangles data for redrawing.
  _updateClimax() {
    if (!isTranslating && !isScaling) {
      _refreshFollowerCamera();
    }

    _bodyRect = Rect.fromCenter(center: _computeClimaxCenter(), width: bodyWidth, height: bodyHeight);
    _leftArmRect = Rect.fromCircle(center: _leftArmOffset, radius: radius);
    _rightArmRect = Rect.fromCircle(center: _rightArmOffset, radius: radius);
    _leftLegRect = Rect.fromCircle(center: _leftLegOffset, radius: radius);
    _rightLegRect = Rect.fromCircle(center: _rightLegOffset, radius: radius);

    // _previousClimaxLimbs = _climaxLimbs;

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

    final newPos =  (newPosition + deltaTranslateAll - climaxCenter) / scaleAll + climaxCenter;

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
        _leftArmOffset = newPos;
        break;

      case ClimaxLimbEnum.RIGHT_ARM:
        _rightArmOffset = newPos;
        break;

      case ClimaxLimbEnum.RIGHT_LEG:
        _rightLegOffset = newPos;
        break;

      case ClimaxLimbEnum.LEFT_LEG:
        _leftLegOffset = newPos;
        break;
      default:
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

    // Return if no limb is selected
    if (this.selectedLimb == null) return;

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
      default:
        break;
    }

    _updateClimax();
  }
}
