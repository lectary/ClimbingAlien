import 'package:climbing_alien/data/entity/wall.dart';
import 'package:floor/floor.dart';

@dao
abstract class WallDao {
  @Query('SELECT * FROM walls')
  Stream<List<Wall>> watchAllWalls();

  @Query('SELECT * FROM walls')
  Future<List<Wall>> fetchAllWalls();

  @insert
  Future<void> insertWall(Wall wall);

  @update
  Future<void> updateWall(Wall wall);

  @delete
  Future<void> deleteWall(Wall wall);
}
