import 'package:climbing_alien/data/entity/base_object.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:floor/floor.dart';

@Entity(tableName: 'grasps', foreignKeys: [
  ForeignKey(childColumns: ['route_id'], parentColumns: ['id'], entity: Route)
])
class Grasp extends BaseObject {
  /// Used to indicate the sequence of grasps per route
  int order;

  @ColumnInfo(name: 'route_id', nullable: false)
  int routeId;

  // TODO add data for climax position

  Grasp(this.order, this.routeId, {int id, DateTime modifiedAt, DateTime createdAt}) : super(id, modifiedAt, createdAt);
}
