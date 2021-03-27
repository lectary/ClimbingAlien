import 'dart:math';

class Utils {
  /// Helper function for converting degress to radians
  static num degreesToRadians(num deg) {
    return (deg * pi) / 180.0;
  }

  static String getFilenameFromPath(String? path) {
    if (path == null) return "";
    int lastSlash = path.lastIndexOf('/');
    int lastDot = path.lastIndexOf('.');
    if (lastSlash == -1 || lastDot == -1) return "";
    return path.substring(lastSlash + 1, lastDot);
  }
}