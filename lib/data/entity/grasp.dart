import 'package:climbing_alien/data/entity/base_object.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart' hide Route;

@Entity(tableName: 'grasps', foreignKeys: [
  ForeignKey(childColumns: ['route_id'], parentColumns: ['id'], entity: Route)
],)
class Grasp extends BaseObject {
  /// Used to indicate the sequence of grasps per route
  @ColumnInfo(name: 'order', nullable: false)
  int order;

  @ColumnInfo(name: 'route_id', nullable: false)
  int routeId;

  @ColumnInfo(name: 'scale_background', nullable: false)
  double scaleBackground;
  @ColumnInfo(name: 'scale_all', nullable: false)
  double scaleAll;

  @ColumnInfo(name: 'translate_background', nullable: false)
  Offset translateBackground;
  @ColumnInfo(name: 'translate_all', nullable: false)
  Offset translateAll;

  @ColumnInfo(name: 'climax_position', nullable: false)
  Offset climaxPosition;
  @ColumnInfo(name: 'left_arm', nullable: false)
  Offset leftArm;
  @ColumnInfo(name: 'right_arm', nullable: false)
  Offset rightArm;
  @ColumnInfo(name: 'left_leg', nullable: false)
  Offset leftLeg;
  @ColumnInfo(name: 'right_leg', nullable: false)
  Offset rightLeg;

  Grasp(
      {this.order,
      this.routeId,
      this.scaleBackground,
      this.scaleAll,
      this.translateBackground,
      this.translateAll,
      this.climaxPosition,
      this.leftArm,
      this.rightArm,
      this.leftLeg,
      this.rightLeg,
      int id,
      DateTime modifiedAt,
      DateTime createdAt})
      : super(id, modifiedAt, createdAt);

  @override
  String toString() {
    return 'Grasp{order: $order, routeId: $routeId, scaleBackground: $scaleBackground, scaleAll: $scaleAll, deltaTranslateBackground: $translateBackground, deltaTranslateAll: $translateAll, climaxPosition: $climaxPosition, leftArmOffset: $leftArm, rightArmOffset: $rightArm, leftLegOffset: $leftLeg, rightLegOffset: $rightLeg}';
  }
}
