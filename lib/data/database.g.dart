// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorClimbingDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$ClimbingDatabaseBuilder databaseBuilder(String name) =>
      _$ClimbingDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$ClimbingDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$ClimbingDatabaseBuilder(null);
}

class _$ClimbingDatabaseBuilder {
  _$ClimbingDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$ClimbingDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$ClimbingDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<ClimbingDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$ClimbingDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$ClimbingDatabase extends ClimbingDatabase {
  _$ClimbingDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  WallDao? _wallDaoInstance;

  RouteDao? _routeDaoInstance;

  GraspDao? _graspDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `walls` (`title` TEXT NOT NULL, `description` TEXT, `height` INTEGER, `location` TEXT, `file` TEXT, `isCustom` INTEGER NOT NULL, `id` INTEGER PRIMARY KEY AUTOINCREMENT, `modified_at` INTEGER, `created_at` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `routes` (`title` TEXT NOT NULL, `description` TEXT, `wall_id` INTEGER NOT NULL, `route_option_id` INTEGER, `id` INTEGER PRIMARY KEY AUTOINCREMENT, `modified_at` INTEGER, `created_at` INTEGER NOT NULL, FOREIGN KEY (`wall_id`) REFERENCES `walls` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`route_option_id`) REFERENCES `route_options` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `route_options` (`scale_background` REAL NOT NULL, `translate_background` TEXT NOT NULL, `id` INTEGER PRIMARY KEY AUTOINCREMENT, `modified_at` INTEGER, `created_at` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `grasps` (`order` INTEGER, `route_id` INTEGER NOT NULL, `left_arm` TEXT NOT NULL, `right_arm` TEXT NOT NULL, `left_leg` TEXT NOT NULL, `right_leg` TEXT NOT NULL, `id` INTEGER PRIMARY KEY AUTOINCREMENT, `modified_at` INTEGER, `created_at` INTEGER NOT NULL, FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  WallDao get wallDao {
    return _wallDaoInstance ??= _$WallDao(database, changeListener);
  }

  @override
  RouteDao get routeDao {
    return _routeDaoInstance ??= _$RouteDao(database, changeListener);
  }

  @override
  GraspDao get graspDao {
    return _graspDaoInstance ??= _$GraspDao(database, changeListener);
  }
}

class _$WallDao extends WallDao {
  _$WallDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _wallInsertionAdapter = InsertionAdapter(
            database,
            'walls',
            (Wall item) => <String, Object?>{
                  'title': item.title,
                  'description': item.description,
                  'height': item.height,
                  'location': item.location,
                  'file': item.file,
                  'isCustom': item.isCustom ? 1 : 0,
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverterNonNull.encode(item.createdAt)
                },
            changeListener),
        _wallUpdateAdapter = UpdateAdapter(
            database,
            'walls',
            ['id'],
            (Wall item) => <String, Object?>{
                  'title': item.title,
                  'description': item.description,
                  'height': item.height,
                  'location': item.location,
                  'file': item.file,
                  'isCustom': item.isCustom ? 1 : 0,
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverterNonNull.encode(item.createdAt)
                },
            changeListener),
        _wallDeletionAdapter = DeletionAdapter(
            database,
            'walls',
            ['id'],
            (Wall item) => <String, Object?>{
                  'title': item.title,
                  'description': item.description,
                  'height': item.height,
                  'location': item.location,
                  'file': item.file,
                  'isCustom': item.isCustom ? 1 : 0,
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverterNonNull.encode(item.createdAt)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Wall> _wallInsertionAdapter;

  final UpdateAdapter<Wall> _wallUpdateAdapter;

  final DeletionAdapter<Wall> _wallDeletionAdapter;

  @override
  Stream<List<Wall>> watchAllWalls() {
    return _queryAdapter.queryListStream('SELECT * FROM walls',
        queryableName: 'walls',
        isView: false,
        mapper: (Map<String, Object?> row) => Wall(
            title: row['title'] as String,
            description: row['description'] as String?,
            height: row['height'] as int?,
            location: row['location'] as String?,
            file: row['file'] as String?,
            isCustom: (row['isCustom'] as int) != 0,
            id: row['id'] as int?,
            modifiedAt: _dateTimeConverter.decode(row['modified_at'] as int?),
            createdAt: _dateTimeConverter.decode(row['created_at'] as int)));
  }

  @override
  Future<List<Wall>> fetchAllWalls() async {
    return _queryAdapter.queryList('SELECT * FROM walls',
        mapper: (Map<String, Object?> row) => Wall(
            title: row['title'] as String,
            description: row['description'] as String?,
            height: row['height'] as int?,
            location: row['location'] as String?,
            file: row['file'] as String?,
            isCustom: (row['isCustom'] as int) != 0,
            id: row['id'] as int?,
            modifiedAt: _dateTimeConverter.decode(row['modified_at'] as int?),
            createdAt: _dateTimeConverter.decode(row['created_at'] as int)));
  }

  @override
  Future<int> insertWall(Wall wall) {
    return _wallInsertionAdapter.insertAndReturnId(
        wall, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateWall(Wall wall) async {
    await _wallUpdateAdapter.update(wall, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteWall(Wall wall) async {
    await _wallDeletionAdapter.delete(wall);
  }
}

class _$RouteDao extends RouteDao {
  _$RouteDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _routeInsertionAdapter = InsertionAdapter(
            database,
            'routes',
            (Route item) => <String, Object?>{
                  'title': item.title,
                  'description': item.description,
                  'wall_id': item.wallId,
                  'route_option_id': item.routeOptionId,
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverterNonNull.encode(item.createdAt)
                },
            changeListener),
        _routeOptionInsertionAdapter = InsertionAdapter(
            database,
            'route_options',
            (RouteOption item) => <String, Object?>{
                  'scale_background': item.scaleBackground,
                  'translate_background':
                      _offsetConverterNonNull.encode(item.translateBackground),
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverterNonNull.encode(item.createdAt)
                }),
        _routeUpdateAdapter = UpdateAdapter(
            database,
            'routes',
            ['id'],
            (Route item) => <String, Object?>{
                  'title': item.title,
                  'description': item.description,
                  'wall_id': item.wallId,
                  'route_option_id': item.routeOptionId,
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverterNonNull.encode(item.createdAt)
                },
            changeListener),
        _routeOptionUpdateAdapter = UpdateAdapter(
            database,
            'route_options',
            ['id'],
            (RouteOption item) => <String, Object?>{
                  'scale_background': item.scaleBackground,
                  'translate_background':
                      _offsetConverterNonNull.encode(item.translateBackground),
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverterNonNull.encode(item.createdAt)
                }),
        _routeDeletionAdapter = DeletionAdapter(
            database,
            'routes',
            ['id'],
            (Route item) => <String, Object?>{
                  'title': item.title,
                  'description': item.description,
                  'wall_id': item.wallId,
                  'route_option_id': item.routeOptionId,
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverterNonNull.encode(item.createdAt)
                },
            changeListener),
        _routeOptionDeletionAdapter = DeletionAdapter(
            database,
            'route_options',
            ['id'],
            (RouteOption item) => <String, Object?>{
                  'scale_background': item.scaleBackground,
                  'translate_background':
                      _offsetConverterNonNull.encode(item.translateBackground),
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverterNonNull.encode(item.createdAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Route> _routeInsertionAdapter;

  final InsertionAdapter<RouteOption> _routeOptionInsertionAdapter;

  final UpdateAdapter<Route> _routeUpdateAdapter;

  final UpdateAdapter<RouteOption> _routeOptionUpdateAdapter;

  final DeletionAdapter<Route> _routeDeletionAdapter;

  final DeletionAdapter<RouteOption> _routeOptionDeletionAdapter;

  @override
  Stream<List<Route>> watchAllRoutes() {
    return _queryAdapter.queryListStream('SELECT * FROM routes',
        queryableName: 'routes',
        isView: false,
        mapper: (Map<String, Object?> row) => Route(
            row['title'] as String, row['wall_id'] as int,
            routeOptionId: row['route_option_id'] as int?,
            description: row['description'] as String?,
            id: row['id'] as int?,
            modifiedAt: _dateTimeConverter.decode(row['modified_at'] as int?),
            createdAt: _dateTimeConverter.decode(row['created_at'] as int)));
  }

  @override
  Stream<List<Route>> watchAllRoutesByWallId(int wallId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM routes WHERE wall_id = ?',
        arguments: [wallId],
        queryableName: 'routes',
        isView: false,
        mapper: (Map<String, Object?> row) => Route(
            row['title'] as String, row['wall_id'] as int,
            routeOptionId: row['route_option_id'] as int?,
            description: row['description'] as String?,
            id: row['id'] as int?,
            modifiedAt: _dateTimeConverter.decode(row['modified_at'] as int?),
            createdAt: _dateTimeConverter.decode(row['created_at'] as int)));
  }

  @override
  Future<List<Route>> findAllRoutes() async {
    return _queryAdapter.queryList('SELECT * FROM routes',
        mapper: (Map<String, Object?> row) => Route(
            row['title'] as String, row['wall_id'] as int,
            routeOptionId: row['route_option_id'] as int?,
            description: row['description'] as String?,
            id: row['id'] as int?,
            modifiedAt: _dateTimeConverter.decode(row['modified_at'] as int?),
            createdAt: _dateTimeConverter.decode(row['created_at'] as int)));
  }

  @override
  Future<List<Route>> findAllRoutesByWallId(int wallId) async {
    return _queryAdapter.queryList('SELECT * FROM routes WHERE wall_id = ?',
        arguments: [wallId],
        mapper: (Map<String, Object?> row) => Route(
            row['title'] as String, row['wall_id'] as int,
            routeOptionId: row['route_option_id'] as int?,
            description: row['description'] as String?,
            id: row['id'] as int?,
            modifiedAt: _dateTimeConverter.decode(row['modified_at'] as int?),
            createdAt: _dateTimeConverter.decode(row['created_at'] as int)));
  }

  @override
  Future<RouteOption?> findRouteOptionById(int optionId) async {
    return _queryAdapter.query('SELECT * FROM route_options WHERE id = ?',
        arguments: [optionId],
        mapper: (Map<String, Object?> row) => RouteOption(
            scaleBackground: row['scale_background'] as double,
            translateBackground: _offsetConverterNonNull
                .decode(row['translate_background'] as String),
            id: row['id'] as int?,
            modifiedAt: _dateTimeConverter.decode(row['modified_at'] as int?),
            createdAt: _dateTimeConverter.decode(row['created_at'] as int)));
  }

  @override
  Future<void> insertRoute(Route route) async {
    await _routeInsertionAdapter.insert(route, OnConflictStrategy.abort);
  }

  @override
  Future<int> insertRouteOption(RouteOption routeOption) {
    return _routeOptionInsertionAdapter.insertAndReturnId(
        routeOption, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateRoute(Route route) async {
    await _routeUpdateAdapter.update(route, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateRouteOption(RouteOption routeOption) async {
    await _routeOptionUpdateAdapter.update(
        routeOption, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteRoute(Route route) async {
    await _routeDeletionAdapter.delete(route);
  }

  @override
  Future<void> deleteRouteOption(RouteOption routeOption) async {
    await _routeOptionDeletionAdapter.delete(routeOption);
  }
}

class _$GraspDao extends GraspDao {
  _$GraspDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _graspInsertionAdapter = InsertionAdapter(
            database,
            'grasps',
            (Grasp item) => <String, Object?>{
                  'order': item.order,
                  'route_id': item.routeId,
                  'left_arm': _offsetConverterNonNull.encode(item.leftArm),
                  'right_arm': _offsetConverterNonNull.encode(item.rightArm),
                  'left_leg': _offsetConverterNonNull.encode(item.leftLeg),
                  'right_leg': _offsetConverterNonNull.encode(item.rightLeg),
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverterNonNull.encode(item.createdAt)
                },
            changeListener),
        _graspUpdateAdapter = UpdateAdapter(
            database,
            'grasps',
            ['id'],
            (Grasp item) => <String, Object?>{
                  'order': item.order,
                  'route_id': item.routeId,
                  'left_arm': _offsetConverterNonNull.encode(item.leftArm),
                  'right_arm': _offsetConverterNonNull.encode(item.rightArm),
                  'left_leg': _offsetConverterNonNull.encode(item.leftLeg),
                  'right_leg': _offsetConverterNonNull.encode(item.rightLeg),
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverterNonNull.encode(item.createdAt)
                },
            changeListener),
        _graspDeletionAdapter = DeletionAdapter(
            database,
            'grasps',
            ['id'],
            (Grasp item) => <String, Object?>{
                  'order': item.order,
                  'route_id': item.routeId,
                  'left_arm': _offsetConverterNonNull.encode(item.leftArm),
                  'right_arm': _offsetConverterNonNull.encode(item.rightArm),
                  'left_leg': _offsetConverterNonNull.encode(item.leftLeg),
                  'right_leg': _offsetConverterNonNull.encode(item.rightLeg),
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverterNonNull.encode(item.createdAt)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Grasp> _graspInsertionAdapter;

  final UpdateAdapter<Grasp> _graspUpdateAdapter;

  final DeletionAdapter<Grasp> _graspDeletionAdapter;

  @override
  Stream<List<Grasp>> watchAllGrasps() {
    return _queryAdapter.queryListStream('SELECT * FROM grasps',
        queryableName: 'grasps',
        isView: false,
        mapper: (Map<String, Object?> row) => Grasp(
            order: row['order'] as int?,
            routeId: row['route_id'] as int,
            leftArm: _offsetConverterNonNull.decode(row['left_arm'] as String),
            rightArm:
                _offsetConverterNonNull.decode(row['right_arm'] as String),
            leftLeg: _offsetConverterNonNull.decode(row['left_leg'] as String),
            rightLeg:
                _offsetConverterNonNull.decode(row['right_leg'] as String),
            id: row['id'] as int?,
            modifiedAt: _dateTimeConverter.decode(row['modified_at'] as int?),
            createdAt: _dateTimeConverter.decode(row['created_at'] as int)));
  }

  @override
  Stream<List<Grasp>> watchAllGraspsByRouteId(int routeId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM grasps WHERE route_id = ?',
        arguments: [routeId],
        queryableName: 'grasps',
        isView: false,
        mapper: (Map<String, Object?> row) => Grasp(
            order: row['order'] as int?,
            routeId: row['route_id'] as int,
            leftArm: _offsetConverterNonNull.decode(row['left_arm'] as String),
            rightArm:
                _offsetConverterNonNull.decode(row['right_arm'] as String),
            leftLeg: _offsetConverterNonNull.decode(row['left_leg'] as String),
            rightLeg:
                _offsetConverterNonNull.decode(row['right_leg'] as String),
            id: row['id'] as int?,
            modifiedAt: _dateTimeConverter.decode(row['modified_at'] as int?),
            createdAt: _dateTimeConverter.decode(row['created_at'] as int)));
  }

  @override
  Future<List<Grasp>> findAllByRouteId(int routeId) async {
    return _queryAdapter.queryList('SELECT * FROM grasps WHERE route_id = ?',
        arguments: [routeId],
        mapper: (Map<String, Object?> row) => Grasp(
            order: row['order'] as int?,
            routeId: row['route_id'] as int,
            leftArm: _offsetConverterNonNull.decode(row['left_arm'] as String),
            rightArm:
                _offsetConverterNonNull.decode(row['right_arm'] as String),
            leftLeg: _offsetConverterNonNull.decode(row['left_leg'] as String),
            rightLeg:
                _offsetConverterNonNull.decode(row['right_leg'] as String),
            id: row['id'] as int?,
            modifiedAt: _dateTimeConverter.decode(row['modified_at'] as int?),
            createdAt: _dateTimeConverter.decode(row['created_at'] as int)));
  }

  @override
  Future<void> insertGrasp(Grasp grasp) async {
    await _graspInsertionAdapter.insert(grasp, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateGrasp(Grasp grasp) async {
    await _graspUpdateAdapter.update(grasp, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteGrasp(Grasp grasp) async {
    await _graspDeletionAdapter.delete(grasp);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
final _dateTimeConverterNonNull = DateTimeConverterNonNull();
final _offsetConverter = OffsetConverter();
final _offsetConverterNonNull = OffsetConverterNonNull();
