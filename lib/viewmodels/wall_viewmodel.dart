import 'dart:io';

import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class WallViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;

  WallViewModel({@required ClimbingRepository climbingRepository})
      : assert(climbingRepository != null),
        _climbingRepository = climbingRepository;

  Stream<List<Wall>> get wallStream => _climbingRepository.watchAllWalls();

  Future<void> insertWall(Wall wall) async {
    if (wall.file != null && !wall.file.startsWith('assets')) {
      String newPath = await _saveImageToDevice(wall.file);
      wall.file = newPath;
    }
    return _climbingRepository.insertWall(wall);
  }

  Future<void> updateWall(Wall wall) async {
    if (wall.file != wall.fileUpdated) {
      wall.file = wall.fileUpdated;
      if (!wall.file.startsWith('assets')) {
        String newPath = await _saveImageToDevice(wall.file);
        wall.file = newPath;
      }
    }
    return _climbingRepository.updateWall(wall);
  }

  Future<void> deleteWall(Wall wall) {
    if (!wall.file.startsWith('assets')) {
      _deleteImageFromDevice(wall.file);
    }
    return _climbingRepository.deleteWall(wall);
  }

  Future<String> _saveImageToDevice(String imagePath) async {
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
