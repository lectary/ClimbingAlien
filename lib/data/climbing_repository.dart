import 'package:climbing_alien/data/api/climbr_api.dart';
import 'package:climbing_alien/data/database.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/route_option.dart';
import 'package:climbing_alien/data/entity/wall.dart';

class ClimbingRepository {
  final ClimbingDatabase _climbingDatabase;
  final ClimbrApi _climbrApi;

  ClimbingRepository({required ClimbingDatabase climbingDatabase, required ClimbrApi climbrApi})
      : _climbingDatabase = climbingDatabase,
        _climbrApi = climbrApi;

  /// Walls
  Stream<List<Wall>> watchAllWalls() {
    return _climbingDatabase.wallDao.watchAllWalls();
  }

  Future<List<Wall>> fetchAllWalls() {
    return _climbingDatabase.wallDao.fetchAllWalls();
  }

  Future<List<Wall>> fetchAllWallsFromApi() {
    return _climbrApi.fetchWalls();
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

  Stream<List<Route>> watchAllRoutesByWallId(int wallId) {
    return _climbingDatabase.routeDao.watchAllRoutesByWallId(wallId);
  }

  Future<List<Route>> findAllRoutes() {
    return _climbingDatabase.routeDao.findAllRoutes();
  }

  Future<List<Route>> findAllRoutesByWallId(int wallId) {
    return _climbingDatabase.routeDao.findAllRoutesByWallId(wallId);
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

  /// Route option
  Future<RouteOption?> findRouteOptionById(int optionId) {
    return _climbingDatabase.routeDao.findRouteOptionById(optionId);
  }

  Future<int> insertRouteOption(RouteOption routeOption) {
    return _climbingDatabase.routeDao.insertRouteOption(routeOption);
  }

  Future<void> updateRouteOption(RouteOption routeOption) {
    return _climbingDatabase.routeDao.updateRouteOption(routeOption);
  }

  Future<void> deleteRouteOption(RouteOption routeOption) {
    return _climbingDatabase.routeDao.deleteRouteOption(routeOption);
  }

  /// Grasps
  Stream<List<Grasp>> watchAllGrasps() {
    return _climbingDatabase.graspDao.watchAllGrasps();
  }

  Stream<List<Grasp>> watchAllGraspsByRouteId(int routeId) {
    return _climbingDatabase.graspDao.watchAllGraspsByRouteId(routeId);
  }

  Future<List<Grasp>> findAllGraspsByRouteId(int routeId) {
    return _climbingDatabase.graspDao.findAllByRouteId(routeId);
  }

  Future<void> insertGrasp(Grasp grasp) {
    return _climbingDatabase.graspDao.insertGrasp(grasp);
  }

  Future<void> updateGrasp(Grasp grasp) {
    return _climbingDatabase.graspDao.updateGrasp(grasp);
  }

  Future<void> deleteGrasp(Grasp grasp) {
    return _climbingDatabase.graspDao.deleteGrasp(grasp);
  }
}
