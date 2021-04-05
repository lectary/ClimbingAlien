import 'dart:async';

import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:flutter/foundation.dart';

class RouteViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;

  Wall? wall;
  List<Route> routeList = List.empty();

  StreamController<List<Route>> routeStreamController = StreamController<List<Route>>();

  Stream<List<Route>> get routeStream => routeStreamController.stream;
  StreamSubscription<List<Route>>? routeStreamSubscription;

  RouteViewModel({required ClimbingRepository climbingRepository, this.wall})
      : _climbingRepository = climbingRepository {
    loadRoutesByWall(wall);
  }

  @override
  void dispose() {
    routeStreamController.close();
    routeStreamSubscription?.cancel();
    super.dispose();
  }

  void loadRoutesByWall(Wall? wall) async {
    if (wall == null) return;
    if (wall.id == null) {
      routeStreamController.sink.add([]);
    } else {
      routeStreamSubscription?.cancel();
      routeStreamSubscription = _climbingRepository.watchAllRoutesByWallId(wall.id!).listen((event) {
        print("new route list");
        routeStreamController.sink.add(event);
      });
    }
  }

  Future<void> insertRoute(Route route) {
    return _climbingRepository.insertRoute(route);
  }

  Future<void> updateRoute(Route route) {
    return _climbingRepository.updateRoute(route);
  }

  Future<void> deleteRoute(Route route) async {
    // Deletes all grasps from route
    List<Grasp> graspByRoute = await _climbingRepository.findAllGraspsByRouteId(route.id!);
    await Future.forEach(graspByRoute, (Grasp grasp) => _climbingRepository.deleteGrasp(grasp));
    await _climbingRepository.deleteRoute(route);
    // Check whether route's wall has other routes anymore
    List<Route> routesOfWall = await _climbingRepository.findAllRoutesByWallId(route.wallId);
    // Delete locally persisted wall if it has no routes
    if (routesOfWall.isEmpty) {
      print("deleting empty wall");
      Wall emptyWallToDelete = await _climbingRepository
          .fetchAllWalls()
          .then((List<Wall> wallList) => wallList.firstWhere((Wall wall) => wall.id == route.wallId));
      await _climbingRepository.deleteWall(emptyWallToDelete);
    } else {
      return;
    }
  }

  Future<void> insertRouteWithWall(Route route, Wall wall) async {
    int newWallId = await _climbingRepository.insertWall(wall);
    // TODO download wall image file
    await _climbingRepository.insertRoute(route..wallId = newWallId);
    loadRoutesByWall(wall..id = newWallId);
  }

  /// Grasps
  Stream<List<Grasp>> getGraspStreamByRouteId(int routeId) => _climbingRepository.watchAllGraspsByRouteId(routeId);
}
