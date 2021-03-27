import 'dart:io';

import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class WallViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;

  WallViewModel({required ClimbingRepository climbingRepository}) : _climbingRepository = climbingRepository;

  Stream<List<Wall>> get wallStream => _climbingRepository.watchAllWalls();

  Future<void> insertWall(Wall wall) async {
    if (wall.imagePath != null && !wall.imagePath!.startsWith('assets')) {
      String? newPath = await _saveImageToDevice(wall.imagePath!);
      wall.imagePath = newPath;
    }
    return _climbingRepository.insertWall(wall);
  }

  Future<void> updateWall(Wall wall) async {
    if (wall.imagePath != wall.imagePathUpdated) {
      wall.imagePath = wall.imagePathUpdated;
      if (!wall.imagePath!.startsWith('assets')) {
        String? newPath = await _saveImageToDevice(wall.imagePath!);
        wall.imagePath = newPath;
      }
    }
    return _climbingRepository.updateWall(wall);
  }

  Future<void> deleteWall(Wall wall) {
    if (!wall.imagePath!.startsWith('assets')) {
      _deleteImageFromDevice(wall.imagePath!);
    }
    return _climbingRepository.deleteWall(wall);
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
