import 'dart:async';

import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:flutter/foundation.dart';

class RouteViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;

  StreamSubscription<List<Route>> routeListener;
  StreamSubscription<List<Grasp>> graspListener;

  RouteViewModel({@required ClimbingRepository climbingRepository})
      : assert(climbingRepository != null),
        _climbingRepository = climbingRepository {
    routeListener = _climbingRepository.watchAllRoutes().listen(getRoutesWithGraspByRouteList);
    graspListener = _climbingRepository.watchAllGrasps().listen(getRoutesWithGraspByGraspList);
  }

  @override
  void dispose() {
    super.dispose();
    routeStreamController.close();
    routeListener.cancel();
    graspListener.cancel();
  }

  StreamController<List<Route>> routeStreamController = StreamController<List<Route>>();
  Stream<List<Route>> get routeStream => routeStreamController.stream.asBroadcastStream();

  void getRoutesWithGraspByRouteList(List<Route> routeList) async {
    List<Route> routesWithGrasps = await Future.wait(routeList.map((route) async {
      route.graspList = await _climbingRepository.findAllGraspsByRouteId(route.id);
      return route;
    }).toList());
    routeStreamController.sink.add(routesWithGrasps);
  }

  void getRoutesWithGraspByGraspList(List<Grasp> graspList) async {
    List<Route> routesWithGrasps = await _climbingRepository.findAllRoutes().then((routeList) => routeList.map((route) {
      route.graspList = graspList.where((element) => element.routeId == route.id).toList();
      return route;
    }).toList());
    routeStreamController.sink.add(routesWithGrasps);
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
}
