import 'dart:async';

import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/route_option.dart';
import 'package:flutter/foundation.dart';

class RouteViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;

  RouteViewModel({required ClimbingRepository climbingRepository}) : _climbingRepository = climbingRepository;

  /// Routes
  Stream<List<Route>> getRouteStreamByWallId(int wallId) => _climbingRepository.watchAllRoutesByWallId(wallId);

  Future<void> insertRoute(Route route) {
    return _climbingRepository.insertRoute(route);
  }

  Future<void> updateRoute(Route route) {
    return _climbingRepository.updateRoute(route);
  }

  Future<void> deleteRoute(Route route) {
    return _climbingRepository.deleteRoute(route);
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
