import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:floor/floor.dart';

@dao
abstract class GraspDao {
  @Query('SELECT * FROM grasps')
  Stream<List<Grasp>> watchAllGrasps();

  @Query('SELECT * FROM grasps WHERE route_id = :routeId')
  Future<List<Grasp>> findAllByRouteId(int routeId);

  @insert
  @OnConflictStrategy.replace
  Future<void> insertGrasp(Grasp grasp);

  @update
  Future<void> updateGrasp(Grasp grasp);

  @delete
  Future<void> deleteGrasp(Grasp grasp);
}
