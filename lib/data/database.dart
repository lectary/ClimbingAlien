import 'dart:async';

import 'package:climbing_alien/data/dao/grasp_dao.dart';
import 'package:climbing_alien/data/dao/route_dao.dart';
import 'package:climbing_alien/data/dao/wall_dao.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/route_option.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/data/type_converters.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart'; // the generated code will be there

@TypeConverters([DateTimeConverter, DateTimeConverterNonNull, OffsetConverter, OffsetConverterNonNull])
@Database(version: 1, entities: [Wall, Route, RouteOption, Grasp])
abstract class ClimbingDatabase extends FloorDatabase {
  WallDao get wallDao;

  RouteDao get routeDao;

  GraspDao get graspDao;
}

class DatabaseProvider {
  static final _instance = DatabaseProvider._internal();
  static DatabaseProvider instance = _instance;

  DatabaseProvider._internal();

  static ClimbingDatabase? _db;

  Future<ClimbingDatabase> get db async {
    if (_db == null) {
      _db = await $FloorClimbingDatabase.databaseBuilder('climbing.db').addCallback(callback).build();
    }
    return _db!;
  }

  Future<void> closeDB() async {
    if (_db != null) {
      _db!.close();
    }
  }

  /// insert mock data
  final callback = Callback(onCreate: (database, version) {
    Wall wall1 = Wall('Wand1',
        location: "Reith",
        description: 'Super wand 1000',
        file: 'assets/images/climbing_walls/reith-pantarai-1.jpg',
        id: 1);
    Wall wall2 = Wall('Boulder1',
        location: "Reith",
        description: 'Schwierig',
        file: 'assets/images/climbing_walls/reith-pantarai-2.jpg',
        id: 2);
    Wall wall3 = Wall('Wand1', location: "Custom", description: 'Schwierig', id: 3);
    database.insert('walls', wall1.toMap());
    database.insert('walls', wall2.toMap());
    database.insert('walls', wall3.toMap());

    Route route1 = Route('Favo', 1, description: 'Blaue Schwierigkeit', id: 1);
    Route route2 = Route('Black Route', 1, description: 'Anstrengend!', id: 2);
    database.insert('routes', route1.toMap());
    database.insert('routes', route2.toMap());
  });
}
