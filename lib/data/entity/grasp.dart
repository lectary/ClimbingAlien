import 'package:climbing_alien/data/entity/base_object.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart' hide Route;

@Entity(tableName: 'grasps', foreignKeys: [
  ForeignKey(childColumns: ['route_id'], parentColumns: ['id'], entity: Route)
],)
class Grasp extends BaseObject {
  /// Used to indicate the sequence of grasps per route
  @ColumnInfo(name: 'order')
  int? order;

  @ColumnInfo(name: 'route_id')
  int routeId;

  @ColumnInfo(name: 'scale_background')
  double? scaleBackground;
  @ColumnInfo(name: 'scale_all')
  double? scaleAll;

  @ColumnInfo(name: 'translate_background')
  Offset? translateBackground;
  @ColumnInfo(name: 'translate_all')
  Offset? translateAll;

  @ColumnInfo(name: 'left_arm')
  Offset leftArm;
  @ColumnInfo(name: 'right_arm')
  Offset rightArm;
  @ColumnInfo(name: 'left_leg')
  Offset leftLeg;
  @ColumnInfo(name: 'right_leg')
  Offset rightLeg;

  Grasp(
      {this.order,
      required this.routeId,
      this.scaleBackground,
      this.scaleAll,
      this.translateBackground,
      this.translateAll,
      required this.leftArm,
      required this.rightArm,
      required this.leftLeg,
      required this.rightLeg,
      int? id,
      DateTime? modifiedAt,
      DateTime? createdAt})
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
