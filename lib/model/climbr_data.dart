import 'package:climbing_alien/data/entity/wall.dart';

/// Represents the data obtained by the ClimbrApi.
class ClimbrData {
  List<Wall> walls;

  ClimbrData({required this.walls});

  factory ClimbrData.fromJson(Map<String, dynamic> json) {
    List<dynamic> jsonWalls = json['walls'];
    List<Wall> walls = jsonWalls.map((jsonWall) => Wall.fromJson(jsonWall)).toList();
    return ClimbrData(
      walls: walls,
    );
  }

  @override
  String toString() {
    return 'ClimbrData{walls: $walls}';
  }
}
