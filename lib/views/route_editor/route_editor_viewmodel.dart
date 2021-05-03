import 'dart:async';

import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/route_option.dart';
import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:flutter/material.dart' hide Route;

enum ModelState { IDLE, LOADING }

/// ViewModel for [Grasp] management as well as initMode handling.
/// Depends on [ClimaxViewModel] for updating climax based on the current [Grasp].
/// Uses [ModelState] to indicate initial loading process.
class RouteEditorViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;
  final ClimaxViewModel climaxViewModel;
  final Route route;
  final Size size;

  /// Entity with additional info about a route (e.g. transformations of background image).
  RouteOption? _routeOption;

  ModelState _state = ModelState.LOADING;

  ModelState get state => _state;

  set state(ModelState state) {
    _state = state;
    notifyListeners();
  }

  late StreamSubscription _graspStreamSubscription;

  RouteEditorViewModel(
      {required this.route,
      required this.size,
      required ClimbingRepository climbingRepository,
      required this.climaxViewModel})
      : _climbingRepository = climbingRepository {
    print('RouteEditorViewModel created');
    _startWatchingGrasps(route);
    // Callback executed by climaxViewModel whenever a current grasp is updated
    climaxViewModel.updateCallback = _updateCallback;
  }

  /// Used for automatically updating the current grasp when the joystick is released, joystick button clicked,
  /// or a tap is executed.
  void _updateCallback() {
    if (step <= graspList.length) {
      print("Updating!");
      Grasp graspToUpdate = climaxViewModel.getCurrentPosition()
        ..id = graspList[step - 1].id
        ..order = graspList[step - 1].order
        ..routeId = graspList[step - 1].routeId;
      _updateGrasp(graspToUpdate);
    }
  }

  @override
  void dispose() {
    _graspStreamSubscription.cancel();
    super.dispose();
  }

  void _graspListener(List<Grasp> _graspList) {
    graspList = List.from(_graspList);
  }

  void _startWatchingGrasps(Route route) async {
    state = ModelState.LOADING;

    // InitMode
    // Check whether a routeOption is available and use it for setting up the background transformations
    if (route.routeOptionId != null) {
      _routeOption = await _climbingRepository.findRouteOptionById(route.routeOptionId!);
      if (_routeOption != null) {
        initMode = false;
        _setupBackgroundByRouteOption(_routeOption!);
      } else {
        initMode = true;
      }
    } else {
      initMode = true;
    }

    // Query all grasps and save them locally
    await _climbingRepository.findAllGraspsByRouteId(route.id!).then((event) {
      _graspList = List.from(event);
      route.graspList = _graspList;

      if (initMode) {
        resetClimax(size);
      } else if (graspList.isNotEmpty) {
        climaxViewModel.setupByGrasp(graspList[step - 1]);
      } else {
        resetClimax(size);
        climaxViewModel.updateGhost();
      }
    });

    // initMode or empty graspList always implies editMode
    editMode = editMode || graspList.isEmpty || initMode;

    state = ModelState.IDLE;
    // Keep watching db stream of grasps
    _graspStreamSubscription = _climbingRepository.watchAllGraspsByRouteId(route.id!).listen(_graspListener);
  }

  /// Edit Mode
  /// Used for switching between strict view mode and step edit mode.
  bool _editMode = false;

  bool get editMode => _editMode;

  set editMode(bool editMode) {
    _editMode = editMode;
    if (!editMode && step > graspList.length) {
      step--;
    }
    notifyListeners();
  }

  ///*****************************************
  /// Init Mode state variables and actions
  ///*****************************************

  /// Init Mode
  /// Allows transforming only the background image independently from climax, where normally, climax and background
  /// are transformed together.
  /// Depends on having [climaxViewModel.transformAll] the value [False] by default.
  bool _initMode = false;

  bool get initMode => _initMode;

  set initMode(bool initMode) {
    if (!initMode && _initMode) {
      _saveRouteOption();
    }
    _initMode = initMode;
    print('InitMode: $initMode');
    climaxViewModel.transformAll = !initMode;
    notifyListeners();
  }

  _saveRouteOption() async {
    if (_routeOption == null) {
      // Create new RouteOption, persist, set new routeOptionId in Route and update
      RouteOption routeOption = RouteOption(
          scaleBackground: climaxViewModel.scaleBackground,
          translateBackground: climaxViewModel.deltaTranslateBackground);
      int routeOptionId = await _climbingRepository.insertRouteOption(routeOption);
      await _climbingRepository.updateRoute(route..routeOptionId = routeOptionId);
      // Cache RouteOption locally
      _routeOption = routeOption;
    } else {
      // Update RouteOption values
      _routeOption!
        ..scaleBackground = climaxViewModel.scaleBackground
        ..translateBackground = climaxViewModel.deltaTranslateBackground;
      _climbingRepository.updateRouteOption(_routeOption!);
    }
  }

  void _setupBackgroundByRouteOption(RouteOption routeOption) {
    climaxViewModel.scaleBackground = routeOption.scaleBackground;
    climaxViewModel.deltaTranslateBackground = routeOption.translateBackground;
  }

  ///*******************************************************************************
  ///*******************************************************************************

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

  bool _joystickOn = true;

  bool get joystickOn => _joystickOn;

  set joystickOn(bool joystickOn) {
    _joystickOn = joystickOn;
    notifyListeners();
  }

  /// Represents the current number of grasp to edit/display.
  /// This is NOT the index of the array, but rather `x of y Grasps`.
  int step = 1;

  resetClimax(Size size) {
    Offset screenCenter = Offset(size.width / 2.0, (size.height - kToolbarHeight) / 2.0);
    climaxViewModel.resetClimax(position: screenCenter);
  }

  ///***********************************************
  /// Grasp Management
  ///***********************************************

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
      _setupGrasp(newGrasp: true); // for step
    } else if (step > graspList.length) {
      print('Saving new grasp');
      climaxViewModel.climaxMoved = false;
      _saveNewGrasp();
    } else {
      _setupGrasp(); // for step
    }
    notifyListeners();
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

  _setupGrasp({bool newGrasp = false}) {
    final currentGrasp = newGrasp ? graspList.last : graspList[step - 1];
    climaxViewModel.setupByGrasp(currentGrasp);
  }

  _saveNewGrasp() {
    Grasp newGrasp = climaxViewModel.getCurrentPosition();
    newGrasp.order = step;
    newGrasp.routeId = route.id!;
    // TODO review - necessary? just rely on db stream propagation?
    graspList.add(newGrasp);
    _insertGrasp(newGrasp);
    climaxViewModel.deselectLimb();
    if (graspList.length > 0) {
      climaxViewModel.updateGhost(previousGrasp: graspList[step - 2]);
    }
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

  ///*******************************************************************************
  ///*******************************************************************************
}
