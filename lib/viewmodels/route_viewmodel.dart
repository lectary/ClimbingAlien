import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:flutter/foundation.dart';

class RouteViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;

  RouteViewModel({@required ClimbingRepository climbingRepository})
      : assert(climbingRepository != null),
        _climbingRepository = climbingRepository;

  List<Route> routeList = List.empty();

  Stream<List<Route>> get routeStream =>
      _climbingRepository.watchAllRoutes().asyncMap((routeList) => Future.wait(routeList.map((route) async {
            route.graspList = await _climbingRepository.findAllGraspsByRouteId(route.id);
            return route;
          }).toList()));


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
