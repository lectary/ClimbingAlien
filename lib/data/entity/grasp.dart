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
    return 'Grasp{order: $order, routeId: $routeId, scaleBackground: $scaleBackground, scaleAll: $scaleAll, translateBackground: $translateBackground, translateAll: $translateAll, leftArm: $leftArm, rightArm: $rightArm, leftLeg: $leftLeg, rightLeg: $rightLeg}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Grasp &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          routeId == other.routeId &&
          scaleBackground == other.scaleBackground &&
          scaleAll == other.scaleAll &&
          translateBackground == other.translateBackground &&
          translateAll == other.translateAll &&
          leftArm == other.leftArm &&
          rightArm == other.rightArm &&
          leftLeg == other.leftLeg &&
          rightLeg == other.rightLeg;

  @override
  int get hashCode =>
      order.hashCode ^
      routeId.hashCode ^
      scaleBackground.hashCode ^
      scaleAll.hashCode ^
      translateBackground.hashCode ^
      translateAll.hashCode ^
      leftArm.hashCode ^
      rightArm.hashCode ^
      leftLeg.hashCode ^
      rightLeg.hashCode;
}
