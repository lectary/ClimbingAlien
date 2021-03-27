import 'package:flutter/cupertino.dart';

class ImageViewModel extends ChangeNotifier {
  String? _currentImagePath;
  String? get currentImagePath => _currentImagePath;
  set currentImagePath(String? currentImagePath) {
    _currentImagePath = currentImagePath;
    notifyListeners();
  }

  void saveImage(String path) {
    currentImagePath = path;
    // TODO persist
  }
}