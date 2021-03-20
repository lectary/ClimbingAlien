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

  void _startWatchingGrasps(int routeId) async {
    state = ModelState.LOADING;

    await _climbingRepository.findAllGraspsByRouteId(routeId).then((event) {
      _graspList = List.from(event);
      if (_graspList.isNotEmpty && initMode) {
        _initMode = false;
      }
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
    // TODO remove - for test purpose only
    // await Future.delayed(Duration(seconds: 1));
    state = ModelState.IDLE;

    // Keep watching db stream of grasps
    _graspStreamSubscription = _climbingRepository.watchAllGraspsByRouteId(routeId).listen(_graspListener);
  }

  void _graspListener(List<Grasp> _graspList) {
    graspList = List.from(_graspList);
  }

  List<Grasp> _graspList = [];
  List<Grasp> get graspList => _graspList;
  set graspList(List<Grasp> graspList) {
    _graspList = graspList;
    notifyListeners();
  }

  /// Init mode allows transforming only the background image independently from climax.
  /// Normally, climax and background are transformed together.
  /// TODO change to true for production
  bool _initMode = false;
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

  deleteCurrentGrasp() {
    final currentGrasp = graspList[step-1];
    _deleteGrasp(currentGrasp);
    --step;
    _setupGrasp();
  }

  _setupGrasp() {
    final currentGrasp = graspList[step - 1];
    climaxViewModel.setupByGrasp(currentGrasp);
  }

  _saveNewGrasp() {
    Grasp newGrasp = climaxViewModel.getCurrentPosition();
    newGrasp.order = step;
    newGrasp.routeId = routeId;
    _insertGrasp(newGrasp);
  }

  Future<void> _insertGrasp(Grasp grasp) {
    return _climbingRepository.insertGrasp(grasp);
  }

Future<void> _updateGrasp(Grasp grasp) {
  return _climbingRepository.updateGrasp(grasp);
}

Future<void> _deleteGrasp(Grasp grasp) {
  return _climbingRepository.deleteGrasp(grasp);
}
}
