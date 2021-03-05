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

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

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
        ? await sqfliteDatabaseFactory.getDatabasePath(name)
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
  _$ClimbingDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  WallDao _wallDaoInstance;

  RouteDao _routeDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
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
            'CREATE TABLE IF NOT EXISTS `walls` (`title` TEXT, `description` TEXT, `height` INTEGER, `image_path` TEXT, `id` INTEGER PRIMARY KEY AUTOINCREMENT, `modified_at` INTEGER, `created_at` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `routes` (`title` TEXT, `description` TEXT, `wall_id` INTEGER NOT NULL, `id` INTEGER PRIMARY KEY AUTOINCREMENT, `modified_at` INTEGER, `created_at` INTEGER NOT NULL, FOREIGN KEY (`wall_id`) REFERENCES `walls` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');

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
}

class _$WallDao extends WallDao {
  _$WallDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _wallInsertionAdapter = InsertionAdapter(
            database,
            'walls',
            (Wall item) => <String, dynamic>{
                  'title': item.title,
                  'description': item.description,
                  'height': item.height,
                  'image_path': item.imagePath,
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverter.encode(item.createdAt)
                },
            changeListener),
        _wallUpdateAdapter = UpdateAdapter(
            database,
            'walls',
            ['id'],
            (Wall item) => <String, dynamic>{
                  'title': item.title,
                  'description': item.description,
                  'height': item.height,
                  'image_path': item.imagePath,
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverter.encode(item.createdAt)
                },
            changeListener),
        _wallDeletionAdapter = DeletionAdapter(
            database,
            'walls',
            ['id'],
            (Wall item) => <String, dynamic>{
                  'title': item.title,
                  'description': item.description,
                  'height': item.height,
                  'image_path': item.imagePath,
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverter.encode(item.createdAt)
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
        mapper: (Map<String, dynamic> row) => Wall(row['title'] as String,
            description: row['description'] as String,
            height: row['height'] as int,
            imagePath: row['image_path'] as String,
            id: row['id'] as int,
            modifiedAt: _dateTimeConverter.decode(row['modified_at'] as int),
            createdAt: _dateTimeConverter.decode(row['created_at'] as int)));
  }

  @override
  Future<void> insertWall(Wall wall) async {
    await _wallInsertionAdapter.insert(wall, OnConflictStrategy.abort);
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
            (Route item) => <String, dynamic>{
                  'title': item.title,
                  'description': item.description,
                  'wall_id': item.wallId,
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverter.encode(item.createdAt)
                },
            changeListener),
        _routeUpdateAdapter = UpdateAdapter(
            database,
            'routes',
            ['id'],
            (Route item) => <String, dynamic>{
                  'title': item.title,
                  'description': item.description,
                  'wall_id': item.wallId,
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverter.encode(item.createdAt)
                },
            changeListener),
        _routeDeletionAdapter = DeletionAdapter(
            database,
            'routes',
            ['id'],
            (Route item) => <String, dynamic>{
                  'title': item.title,
                  'description': item.description,
                  'wall_id': item.wallId,
                  'id': item.id,
                  'modified_at': _dateTimeConverter.encode(item.modifiedAt),
                  'created_at': _dateTimeConverter.encode(item.createdAt)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Route> _routeInsertionAdapter;

  final UpdateAdapter<Route> _routeUpdateAdapter;

  final DeletionAdapter<Route> _routeDeletionAdapter;

  @override
  Stream<List<Route>> watchAllRoutes() {
    return _queryAdapter.queryListStream('SELECT * FROM routes',
        queryableName: 'routes',
        isView: false,
        mapper: (Map<String, dynamic> row) => Route(row['title'] as String,
            row['description'] as String, row['wall_id'] as int,
            id: row['id'] as int,
            modifiedAt: _dateTimeConverter.decode(row['modified_at'] as int),
            createdAt: _dateTimeConverter.decode(row['created_at'] as int)));
  }

  @override
  Future<void> insertRoute(Route route) async {
    await _routeInsertionAdapter.insert(route, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateRoute(Route route) async {
    await _routeUpdateAdapter.update(route, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteRoute(Route route) async {
    await _routeDeletionAdapter.delete(route);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
