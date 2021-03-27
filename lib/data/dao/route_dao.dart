import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/route_option.dart';
import 'package:floor/floor.dart';

@dao
abstract class RouteDao {
  @Query('SELECT * FROM routes')
  Stream<List<Route>> watchAllRoutes();

  @Query('SELECT * FROM routes WHERE wall_id = :wallId')
  Stream<List<Route>> watchAllRoutesByWallId(int wallId);

  @Query('SELECT * FROM routes')
  Future<List<Route>> findAllRoutes();

  @Query('SELECT * FROM routes WHERE wall_id = :wallId')
  Future<List<Route>> findAllRoutesByWallId(int wallId);

  @insert
  Future<void> insertRoute(Route route);

  @update
  Future<void> updateRoute(Route route);

  @delete
  Future<void> deleteRoute(Route route);



  @Query('SELECT * FROM route_options WHERE id = :optionId')
  Future<RouteOption?> findRouteOptionById(int optionId);

  @insert
  Future<int> insertRouteOption(RouteOption routeOption);

  @update
  Future<void> updateRouteOption(RouteOption routeOption);

  @delete
  Future<void> deleteRouteOption(RouteOption routeOption);
}
