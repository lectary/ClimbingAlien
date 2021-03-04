import 'dart:async';

import 'package:climbing_alien/data/dao/route_dao.dart';
import 'package:climbing_alien/data/dao/wall_dao.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/data/type_converters.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart'; // the generated code will be there

@TypeConverters([DateTimeConverter])
@Database(version: 1, entities: [Wall, Route])
abstract class ClimbingDatabase extends FloorDatabase {
  WallDao get wallDao;

  RouteDao get routeDao;
}

class DatabaseProvider {
  static final _instance = DatabaseProvider._internal();
  static DatabaseProvider instance = _instance;

  DatabaseProvider._internal();

  static ClimbingDatabase _db;

  Future<ClimbingDatabase> get db async {
    if (_db == null) {
      _db = await $FloorClimbingDatabase.databaseBuilder('climbing.db').addCallback(callback).build();
    }
    return _db;
  }

  Future<void> closeDB() async {
    if (_db != null) {
      _db.close();
    }
  }

  /// insert mock data
  final callback = Callback(onOpen: (database) {
    // -----
  });
}
