import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Service class for saving and removing images from local device storage.
class StorageService {
  static Future<String> saveToDevice(String filePath) async {
    File outFile = File(filePath);
    String fileName = basename(filePath);

    final directory = await getApplicationDocumentsDirectory();
    String newPath = '${directory.path}/$fileName';

    await outFile.copy(newPath);
    return newPath;
  }

  static Future<void> deleteFromDevice(String filePath) async {
    try {
      await File(filePath).delete();
    } catch (e) {
      print("Failed to delete file: $e");
    }
  }
}
