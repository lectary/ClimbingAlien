import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:flutter/material.dart';

class WallViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;

  WallViewModel({@required ClimbingRepository climbingRepository})
      : assert(climbingRepository != null),
        _climbingRepository = climbingRepository;

  Stream<List<Wall>> get wallStream => _climbingRepository.watchAllWalls();

  Future<void> insertWall(Wall wall) {
    return _climbingRepository.insertWall(wall);
  }

  Future<void> updateWall(Wall wall) {
    return _climbingRepository.updateWall(wall);
  }

  Future<void> deleteWall(Wall wall) {
    return _climbingRepository.deleteWall(wall);
  }
}
