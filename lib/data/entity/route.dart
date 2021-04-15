import 'package:climbing_alien/data/entity/base_object.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route_option.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:floor/floor.dart';

@Entity(tableName: 'routes', foreignKeys: [
  ForeignKey(childColumns: ['wall_id'], parentColumns: ['id'], entity: Wall),
  ForeignKey(childColumns: ['route_option_id'], parentColumns: ['id'], entity: RouteOption)
])
class Route extends BaseObject {
  String title;

  String? description;

  @ColumnInfo(name: 'wall_id')
  int wallId;

  @ColumnInfo(name: 'route_option_id')
  int? routeOptionId;

  @ignore
  List<Grasp>? graspList;

  Route(this.title, this.wallId,
      {this.routeOptionId, this.description, int? id, DateTime? modifiedAt, DateTime? createdAt})
      : super(id, modifiedAt, createdAt);

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "wall_id": wallId,
      "route_option_id": routeOptionId,
      "id": id,
      "modified_at": modifiedAt?.millisecondsSinceEpoch,
      "created_at": createdAt.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'Route{title: $title, description: $description, wallId: $wallId, routeOptionId: $routeOptionId, graspList: $graspList}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Route &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          description == other.description &&
          wallId == other.wallId &&
          routeOptionId == other.routeOptionId;

  @override
  int get hashCode =>
      title.hashCode ^ description.hashCode ^ wallId.hashCode ^ routeOptionId.hashCode;
}
