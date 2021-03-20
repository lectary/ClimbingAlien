import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:flutter/material.dart';

enum State {
  IDLE, LOADING
}

class RouteEditorViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;
  final ClimaxViewModel climaxViewModel;

  State state = State.IDLE;

  RouteEditorViewModel({@required ClimbingRepository climbingRepository, @required this.climaxViewModel})
      : assert(climbingRepository != null && climaxViewModel != null),
        _climbingRepository = climbingRepository {
   initClimax();
  }

  Stream<List<Grasp>> getGraspStreamByRouteId(int routeId) => _climbingRepository.watchAllGraspsByRouteId(routeId);

  /// Init mode allows transforming only the background image independently from climax.
  /// Normally, climax and background are transformed together.
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

  /// Represents the current grasp to edit/display.
  int step = 1;

  initClimax() {
    print('RouteEditorViewModel created');
  }

  // resetClimax(Size size) {
  //   climaxViewModel.resetClimax();
  //   Offset screenCenter = Offset(size.width / 2.0, size.height / 2.0 - kToolbarHeight);
  //   climaxViewModel.updateClimaxPosition(screenCenter);
  // }

  //
  // List<Grasp> graspList = List.empty();
  //
  // Grasp _currentGrasp;
  // Grasp get currentGrasp => _currentGrasp;
  // set currentGrasp(Grasp currentGrasp) {
  //   _currentGrasp = currentGrasp;
  //   notifyListeners();
  // }
  //
  // previousGrasp(ClimaxViewModel model) {
  //   currentGrasp = graspList[--step-1];
  //   model.setupByGrasp(currentGrasp);
  // }
  //
  // nextGrasp(ClimaxViewModel model) {
  //   currentGrasp = graspList[++step-1];
  //   model.setupByGrasp(currentGrasp);
  // }
  //
  //
  Future<void> insertGrasp(Grasp grasp) {
    return _climbingRepository.insertGrasp(grasp);
  }
  //
  // Future<void> updateGrasp(Grasp grasp) {
  //   step--;
  //   return _climbingRepository.updateGrasp(grasp);
  // }
  //
  // Future<void> deleteGrasp(Grasp grasp) {
  //   return _climbingRepository.deleteGrasp(grasp);
  // }
}
