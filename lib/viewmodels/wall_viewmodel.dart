import 'dart:async';
import 'dart:io';

import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/model/location.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

enum ModelState { IDLE, LOADING }

class WallViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;

  ModelState _modelState = ModelState.IDLE;

  ModelState get modelState => _modelState;

  set modelState(ModelState modelState) {
    _modelState = modelState;
    notifyListeners();
  }

  List<Location> locationList = List.empty();
  List<Wall> _wallList = List.empty();

  WallViewModel({required ClimbingRepository climbingRepository}) : _climbingRepository = climbingRepository {
    print("Created WallViewModel");
    loadAllWalls();
    listenToLocalWalls();
  }

  late StreamSubscription<List<Wall>> _wallStreamSubscription;

  listenToLocalWalls() {
    _wallStreamSubscription = _climbingRepository.watchAllWalls().listen((wallList) {
      updateCachedWallsAndLocations(wallList);
    });
  }

  @override
  void dispose() {
    _wallStreamSubscription.cancel();
    super.dispose();
  }

  /// Updates the locally cached location and wall list with the passed wall list.
  void updateCachedWallsAndLocations(List<Wall> newLocalList) {
    _wallList = _mergeWalls(localWalls: newLocalList, remoteWalls: _wallList);
    locationList = groupWalls(_wallList);
    notifyListeners();
  }

  /// Loads all walls, local and remote ones.
  /// Returns a [List] of [Location] grouped by [Wall.location].
  void loadAllWalls() async {
    modelState = ModelState.LOADING;

    final localWalls = await _climbingRepository.fetchAllWalls();
    List<Wall> customWalls = [];
    List<Wall> localRemoteWalls = [];
    localWalls.forEach((element) {
      if (element.isCustom) {
        customWalls.add(element);
      } else {
        localRemoteWalls.add(element);
      }
    });
    List<Wall> remoteWalls = await _climbingRepository.fetchAllWallsFromApi();
    _wallList = _mergeWalls(localWalls: localRemoteWalls, remoteWalls: remoteWalls)..addAll(customWalls);

    locationList = groupWalls(_wallList);

    modelState = ModelState.IDLE;
  }

  List<Location> groupWalls(List<Wall> wallList) {
    return groupBy(wallList, (Wall wall) => wall.location)
        .entries
        .map((MapEntry<String?, List<Wall>> entry) => Location(entry.key ?? "<no-name>", entry.value))
        .toList();
  }

  /// Merges two lists of [Wall].
  List<Wall> _mergeWalls({required List<Wall> localWalls, required List<Wall> remoteWalls}) {
    List<Wall> resultList = [];

    // comparing local with remote list and adding all local persisted lectures to the result list and checking if updates are available (i.e. identical lecture with never date)
    localWalls.forEach((local) {
      remoteWalls.forEach((remote) {
        if (local.location == remote.location && local.title == remote.title) {
          resultList.add(local);
        }
      });
    });

    // Check if any local walls are outdated (i.e. not available remotely anymore)
    localWalls.forEach((e1) {
      // If its a custom wall, add it to list, otherwise its a copy from a remote wall, and then it may be deleted
      if (remoteWalls.any((e2) => e1.location == e2.location && e1.title == e2.title) == false) {
        // TODO remove wall and its children automatically or provide a user option
        // _removeWall(e1);
        if (e1.isCustom) {
          resultList.add(e1);
        }
      }
    });

    // Add all remaining and not persisted walls available remotely
    remoteWalls.forEach((e1) {
      if (localWalls.any((e2) => e1.location == e2.location && e1.title == e2.title) == false) {
        // Remove any
        if (e1.isCustom) {
          resultList.remove(e1);
        } else {
          // Set id null, if wall was persisted and then deleted
          if (e1.id != null) {
            e1.id = null;
          }
          resultList.add(e1);
        }
      }
    });

    resultList.sort((wall1, wall2) => wall1.location!.compareTo(wall2.location!));

    return resultList;
  }

  Future<int> insertWall(Wall wall) async {
    if (wall.file != null && !wall.file!.startsWith('assets')) {
      String? newPath = await _saveImageToDevice(wall.file!);
      wall.file = newPath;
    }
    return _climbingRepository.insertWall(wall);
  }

  Future<void> updateWall(Wall wall) async {
    if (wall.file != wall.fileUpdated) {
      wall.file = wall.fileUpdated;
      if (!wall.file!.startsWith('assets')) {
        String? newPath = await _saveImageToDevice(wall.file!);
        wall.file = newPath;
      }
    }
    return _climbingRepository.updateWall(wall);
  }

  Future<bool> deleteWall(Wall wall, {bool cascade = false}) async {
    print("Deleting wall with name: " + wall.title.toString());

    if (!(wall.file?.startsWith('assets') ?? true)) {
      _deleteImageFromDevice(wall.file!);
    }
    List<Route> routesOfWall = await _climbingRepository.findAllRoutesByWallId(wall.id!);
    if (routesOfWall.isNotEmpty) {
      if (cascade) {
        await Future.forEach(routesOfWall, (Route route) async {
          await _climbingRepository.findAllGraspsByRouteId(route.id!).then((List<Grasp> graspList) async =>
              await Future.forEach(graspList, (Grasp grasp) => _climbingRepository.deleteGrasp(grasp)));
          await _climbingRepository.deleteRoute(route);
        });
        return true;
      } else {
        return false;
      }
    }
    await _climbingRepository.deleteWall(wall);
    return true;
  }

  Future<String?> _saveImageToDevice(String imagePath) async {
    if (imagePath.contains('assets')) return null;
    File tmpFile = File(imagePath);
    final String filename = basename(imagePath); // Filename without extension

    final directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/$filename';
    await tmpFile.copy(filePath);
    return filePath;
  }

  Future<void> _deleteImageFromDevice(String imagePath) async {
    await File(imagePath).delete();
  }

  Future<int> getNumberOfRoutesByWall(Wall wall) async {
    if (wall.id == null) {
      return Future.value(0);
    }
    return await _climbingRepository.findAllRoutesByWallId(wall.id!).then((value) => value.length);
  }
}
