import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/route_option.dart';
import 'package:flutter/material.dart' hide Route;

class RouteViewerScreenViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;

  RouteViewerScreenViewModel({required ClimbingRepository climbingRepository})
      : _climbingRepository = climbingRepository;

  Stream<List<Grasp>> getGraspStreamByRouteId(int routeId) => _climbingRepository.watchAllGraspsByRouteId(routeId);

  Future<RouteOption?> getRouteOption(Route route) {
    if (route.routeOptionId == null) {
      return Future.value(null);
    }
    return _climbingRepository.findRouteOptionById(route.routeOptionId!);
  }
}