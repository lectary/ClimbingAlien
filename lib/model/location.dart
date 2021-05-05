import 'package:climbing_alien/data/entity/wall.dart';

class Location {
  final String? name;
  final List<Wall> walls;

  Location(this.name, this.walls);
}