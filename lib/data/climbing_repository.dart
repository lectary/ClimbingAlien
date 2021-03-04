import 'package:climbing_alien/data/database.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:flutter/foundation.dart';

class ClimbingRepository {
  final ClimbingDatabase _climbingDatabase;

  ClimbingRepository({@required ClimbingDatabase climbingDatabase})
      : assert(climbingDatabase != null),
        _climbingDatabase = climbingDatabase;

  /// Walls
  Stream<List<Wall>> watchAllWalls() {
    return _climbingDatabase.wallDao.watchAllWalls();
  }

  Future<void> insertWall(Wall wall) {
    return _climbingDatabase.wallDao.insertWall(wall);
  }

  Future<void> updateWall(Wall wall) {
    return _climbingDatabase.wallDao.updateWall(wall);
  }

  Future<void> deleteWall(Wall wall) {
    return _climbingDatabase.wallDao.deleteWall(wall);
  }

  /// Routes
  Stream<List<Route>> watchAllRoutes() {
    return _climbingDatabase.routeDao.watchAllRoutes();
  }

  Future<void> insertRoute(Route route) {
    return _climbingDatabase.routeDao.insertRoute(route);
  }

  Future<void> updateRoute(Route route) {
    return _climbingDatabase.routeDao.updateRoute(route);
  }

  Future<void> deleteRoute(Route route) {
    return _climbingDatabase.routeDao.deleteRoute(route);
  }
}
