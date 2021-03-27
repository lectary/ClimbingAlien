import 'package:climbing_alien/data/entity/base_object.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart' hide Route;

@Entity(
  tableName: 'route_options',
)
class RouteOption extends BaseObject {
  @ColumnInfo(name: 'scale_background')
  double scaleBackground;

  @ColumnInfo(name: 'translate_background')
  Offset translateBackground;

  RouteOption(
      {required this.scaleBackground,
      required this.translateBackground,
      int? id,
      DateTime? modifiedAt,
      DateTime? createdAt})
      : super(id, modifiedAt, createdAt);
}
