import 'package:climbing_alien/data/entity/base_object.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:floor/floor.dart';

@Entity(tableName: 'routes', foreignKeys: [
  ForeignKey(childColumns: ['wall_id'], parentColumns: ['id'], entity: Wall)
])
class Route extends BaseObject {
  String title;

  String description;

  @ColumnInfo(name: 'wall_id', nullable: false)
  int wallId;

  Route(this.title, this.wallId, {this.description, int id, DateTime modifiedAt, DateTime createdAt})
      : super(id, modifiedAt, createdAt);

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "wall_id": wallId,
      "id": id,
      "modified_at": modifiedAt?.millisecondsSinceEpoch,
      "created_at": createdAt.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'Route{title: $title, description: $description, wallId: $wallId}';
  }
}
