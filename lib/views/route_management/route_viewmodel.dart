import 'dart:async';

import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/route_option.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:flutter/foundation.dart';

enum ModelState { IDLE, LOADING }

class RouteScreenViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;

  ModelState _modelState = ModelState.IDLE;

  ModelState get modelState => _modelState;

  set modelState(ModelState modelState) {
    _modelState = modelState;
    notifyListeners();
  }

  late Wall wall;
  List<Route> routeList = List.empty();

  RouteScreenViewModel({required ClimbingRepository climbingRepository, required this.wall})
      : _climbingRepository = climbingRepository {
    loadRoutesByWall(wall);
    listenToLocalRoutes();
  }

  StreamSubscription<List<Route>>? _routeStreamSubscription;

  listenToLocalRoutes() {
    if (wall.id == null) {
      return;
    }
    _routeStreamSubscription = _climbingRepository.watchAllRoutesByWallId(wall.id!).listen((wallList) {
      // TODO improve, just update local walls, dont requery remote ones
      loadRoutesByWall(wall);
    });
  }

  @override
  void dispose() {
    _routeStreamSubscription?.cancel();
    super.dispose();
  }

  void loadRoutesByWall(Wall wall) async {
    modelState = ModelState.LOADING;

    if (wall.id != null) {
      routeList = await _climbingRepository.findAllRoutesByWallId(wall.id!);
    }

    modelState = ModelState.IDLE;
  }

  /// Routes
  Stream<List<Route>> getRouteStreamByWallId(int? wallId) {
    // TODO FIX
    if (wallId == null) {
      return Stream.value([]);
    }
    return _climbingRepository.watchAllRoutesByWallId(wallId);
  }

  Future<void> insertRoute(Route route) {
    return _climbingRepository.insertRoute(route);
  }

  Future<void> updateRoute(Route route) {
    return _climbingRepository.updateRoute(route);
  }

  Future<void> deleteRoute(Route route) {
    return _climbingRepository.deleteRoute(route);
  }

  Future<void> insertRouteWithWall(Route route, Wall wall) async {
    int newWallId = await _climbingRepository.insertWall(wall);
    // TODO download wall image file
    await _climbingRepository.insertRoute(route..wallId = newWallId);
  }

  /// Grasps
  Stream<List<Grasp>> getGraspStreamByRouteId(int routeId) => _climbingRepository.watchAllGraspsByRouteId(routeId);

  Future<RouteOption?> getRouteOption(Route route) {
    if (route.routeOptionId == null) {
      return Future.value(null);
    }
    return _climbingRepository.findRouteOptionById(route.routeOptionId!);
  }
}
