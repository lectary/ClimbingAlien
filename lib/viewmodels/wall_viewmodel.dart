import 'dart:async';
import 'dart:io';

import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/model/location.dart';
import 'package:climbing_alien/services/storage_service.dart';
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
  /// This function can handle the case, that [remoteWalls] is a previous merged list (the result of this function).
  List<Wall> _mergeWalls({required List<Wall> localWalls, required List<Wall> remoteWalls}) {
    List<Wall> resultList = [];

    // Comparing local with remote list and adding all local persisted lectures to the result list
    localWalls.forEach((local) {
      remoteWalls.forEach((remote) {
        if (local.location == remote.location && local.title == remote.title) {
          resultList.add(local..status = WallStatus.persisted);
        }
      });
    });

    // Check if any local walls are outdated (i.e. not available remotely anymore)
    localWalls.forEach((local) {
      // If its a custom wall, add it to list, otherwise its a copy from a remote wall, and then it may be deleted
      if (remoteWalls.any((remote) => local.location == remote.location && local.title == remote.title) == false) {
        if (local.isCustom) {
          resultList.add(local..status = WallStatus.persisted);
        } else {
          // TODO remove wall and its children automatically or provide a user option
          resultList.add(local..status = WallStatus.removed);
        }
      }
    });

    // Add all remaining and not persisted walls available remotely
    remoteWalls.forEach((remote) {
      if (localWalls.any((local) => remote.location == local.location && remote.title == local.title) == false) {
        // If wall is a custom one, this indicates, that the passed remoteList was a previous merged list,
        // therefore remove this entry from the result, since it got already added in the loop before.
        if (remote.isCustom) {
          resultList.remove(remote);
        } else {
          // Update id to null, if wall was previously persisted and then deleted
          if (remote.id != null) {
            remote.id = null;
          }
          resultList.add(remote..status = WallStatus.notPersisted);
        }
      }
    });

    resultList.sort((wall1, wall2) => wall1.location!.compareTo(wall2.location!));

    return resultList;
  }

  Future<int> insertWall(Wall wall) async {
    if (wall.filePathUpdated != null) {
      String? newPath = await StorageService.saveToDevice(wall.filePathUpdated!);
      wall.fileName = basename(newPath);
      wall.filePath = newPath;
    }

    return _climbingRepository.insertWall(wall);
  }

  Future<void> updateWall(Wall wall) async {
    if (basename(wall.filePath ?? "") != basename(wall.filePathUpdated ?? "")) {
      await StorageService.deleteFromDevice(wall.filePath);
      String? newPath = await StorageService.saveToDevice(wall.filePathUpdated!);
      wall.fileName = basename(newPath);
      wall.filePath = newPath;
    }
    return _climbingRepository.updateWall(wall);
  }

  Future<bool> deleteWall(Wall wall, {bool cascade = false}) async {
    print("Deleting wall with name: " + wall.title.toString());

    await StorageService.deleteFromDevice(wall.filePath);

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

  Future<int> getNumberOfRoutesByWall(Wall wall) async {
    if (wall.id == null) {
      return Future.value(0);
    }
    return await _climbingRepository.findAllRoutesByWallId(wall.id!).then((value) => value.length);
  }
}
