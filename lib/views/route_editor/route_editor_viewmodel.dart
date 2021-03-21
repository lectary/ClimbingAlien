import 'dart:async';

import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:flutter/material.dart';

enum ModelState {
  IDLE,
  LOADING
}

class RouteEditorViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;
  final ClimaxViewModel climaxViewModel;
  final int routeId;
  final Size size;

  ModelState _state = ModelState.LOADING;
  ModelState get state => _state;

  set state(ModelState state) {
    _state = state;
    notifyListeners();
  }

  StreamSubscription _graspStreamSubscription;

  RouteEditorViewModel(
      {@required this.routeId, @required this.size, @required ClimbingRepository climbingRepository, @required this.climaxViewModel})
      : assert(climbingRepository != null && climaxViewModel != null),
        _climbingRepository = climbingRepository {
    print('RouteEditorViewModel created');
    _startWatchingGrasps(routeId);
  }

  @override
  void dispose() {
    _graspStreamSubscription.cancel();
    super.dispose();
  }

  void _graspListener(List<Grasp> _graspList) {
    graspList = List.from(_graspList);
  }

  void _startWatchingGrasps(int routeId) async {
    state = ModelState.LOADING;

    // query all grasps, and save them locally
    await _climbingRepository.findAllGraspsByRouteId(routeId).then((event) {
      _graspList = List.from(event);
      // Checks whether initMode should be activated or not.
      if (_graspList.isNotEmpty && initMode) {
        initMode = false;
      }
      // If initMode or empty, reset climax to default position, otherwise setup by grasp
      if (initMode) {
        resetClimax(size);
      } else {
        if (graspList.isNotEmpty) {
          climaxViewModel.setupByGrasp(graspList[step-1]);
        } else {
          resetClimax(size); // test
        }
      }
    });
    state = ModelState.IDLE;
    // Keep watching db stream of grasps
    _graspStreamSubscription = _climbingRepository.watchAllGraspsByRouteId(routeId).listen(_graspListener);
  }

  List<Grasp> _graspList = [];
  List<Grasp> get graspList => _graspList;
  set graspList(List<Grasp> graspList) {
    _graspList = graspList;
    /// When no grasp available, permit to save without explicit movement, since the first position
    /// should be valid anyway due to initMode.
    if (_graspList.isEmpty) {
      climaxViewModel.climaxMoved = true;
    }
    notifyListeners();
  }

  /// Init mode allows transforming only the background image independently from climax.
  /// Normally, climax and background are transformed together.
  /// Depends on being [climaxViewModel.transformAll] false by default.
  bool _initMode = true;
  bool get initMode => _initMode;
  set initMode(bool initMode) {
    _initMode = initMode;
    print('InitMode: $initMode');
    climaxViewModel.transformAll = !initMode;
    notifyListeners();
  }

  bool _joystickOn = true;
  bool get joystickOn => _joystickOn;
  set joystickOn(bool joystickOn) {
    _joystickOn = joystickOn;
    notifyListeners();
  }

  /// Represents the current number of grasp to edit/display.
  /// This is NOT the index of the array, but rather `x of y Grasps`.
  int _step = 1;
  int get step => _step;
  set step(int step) {
    _step = step;
  }

  resetClimax(Size size) {
    climaxViewModel.resetClimax();
    Offset screenCenter = Offset(size.width / 2.0, size.height / 2.0 - kToolbarHeight);
    climaxViewModel.updateClimaxPosition(screenCenter);
  }

  previousGrasp() {
    --step;
    _setupGrasp();
    notifyListeners(); // for step
  }

  nextGrasp() {
    ++step;
    if (step == graspList.length + 1) {
      print('Creating new grasp');
      climaxViewModel.climaxMoved = false;
      notifyListeners(); // for step
    } else if (step > graspList.length) {
      print('Saving new grasp');
      climaxViewModel.climaxMoved = false;
      _saveNewGrasp();
    } else {
      _setupGrasp();
      notifyListeners(); // for step
    }
  }

  deleteCurrentGrasp() async {
    final currentGrasp = graspList.removeAt(step - 1);
    _deleteGrasp(currentGrasp);
    if (graspList.length == 0) {
      resetClimax(size);
    } else {
      if (step > 1) {
        --step;
      }
      _setupGrasp();
    }
    notifyListeners();
  }

  _setupGrasp() {
    final currentGrasp = graspList[step - 1];
    climaxViewModel.setupByGrasp(currentGrasp);
  }

  _saveNewGrasp() {
    Grasp newGrasp = climaxViewModel.getCurrentPosition();
    newGrasp.order = step;
    newGrasp.routeId = routeId;
    // TODO review - necessary? just rely on db stream propagation?
    graspList.add(newGrasp);
    _insertGrasp(newGrasp);
  }

  Future<void> _insertGrasp(Grasp grasp) {
    return _climbingRepository.insertGrasp(grasp);
  }

Future<void> _updateGrasp(Grasp grasp) {
  return _climbingRepository.updateGrasp(grasp);
}

Future<void> _deleteGrasp(Grasp grasp) async {
  return await _climbingRepository.deleteGrasp(grasp);
}
}
