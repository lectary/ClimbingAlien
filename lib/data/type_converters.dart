import 'package:floor/floor.dart';
import 'package:flutter/material.dart';

class DateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int databaseValue) {
    return databaseValue == null ? null : DateTime.fromMillisecondsSinceEpoch(databaseValue);
  }

  @override
  int encode(DateTime value) {
    return value == null ? null : value.millisecondsSinceEpoch;
  }
}

class OffsetConverter extends TypeConverter<Offset, String> {
  @override
  Offset decode(String databaseValue) {
    if (databaseValue == null) {
     return null;
    } else {
      List<String> split = databaseValue.split(':');
      return Offset(double.parse(split[0]), double.parse(split[1]));
    }
  }

  @override
  String encode(Offset value) {
    return value == null ? null : "${value.dx}:${value.dy}";
  }
}
