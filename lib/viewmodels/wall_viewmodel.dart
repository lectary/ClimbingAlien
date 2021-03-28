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

class WallViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;

  WallViewModel({required ClimbingRepository climbingRepository}) : _climbingRepository = climbingRepository;

  Stream<List<Location>> get locationStream =>
      _climbingRepository.watchAllWalls().map((wallList) => groupBy(wallList, (Wall wall) => wall.location)
          .entries
          .map((MapEntry<String?, List<Wall>> entry) => Location(entry.key ?? "<no-name>", entry.value))
          .toList());

  Future<List<Location>> loadAllWalls() async {
    List<Wall> localWalls = await _climbingRepository.fetchAllWalls();
    List<Wall> remoteWalls = await _climbingRepository.fetchAllWallsFromApi();

    return groupBy(remoteWalls, (Wall wall) => wall.location)
        .entries
        .map((MapEntry<String?, List<Wall>> entry) => Location(entry.key ?? "<no-name>", entry.value)).toList();
  }

  Future<void> insertWall(Wall wall) async {
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
}
