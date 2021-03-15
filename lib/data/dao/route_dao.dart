import 'package:climbing_alien/data/entity/route.dart';
import 'package:floor/floor.dart';

@dao
abstract class RouteDao {
  @Query('SELECT * FROM routes')
  Stream<List<Route>> watchAllRoutes();

  @Query('SELECT * FROM routes WHERE wall_id = :wallId')
  Stream<List<Route>> watchAllRoutesByWallId(int wallId);

  @Query('SELECT * FROM routes')
  Future<List<Route>> findAllRoutes();

  @insert
  Future<void> insertRoute(Route route);

  @update
  Future<void> updateRoute(Route route);

  @delete
  Future<void> deleteRoute(Route route);
}
