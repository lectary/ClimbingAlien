import 'dart:async';

import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:flutter/foundation.dart';

class RouteViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;

  RouteViewModel({@required ClimbingRepository climbingRepository})
      : assert(climbingRepository != null),
        _climbingRepository = climbingRepository;


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

  Future<void> insertGrasp(Grasp grasp) {
    return _climbingRepository.insertGrasp(grasp);
  }

  Future<void> updateGrasp(Grasp grasp) {
    return _climbingRepository.updateGrasp(grasp);
  }

  Future<void> deleteGrasp(Grasp grasp) {
    return _climbingRepository.deleteGrasp(grasp);
  }
}
