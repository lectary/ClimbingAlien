import 'dart:math';

import 'package:path/path.dart';

class Utils {
  /// Helper function for converting degress to radians
  static num degreesToRadians(num deg) {
    return (deg * pi) / 180.0;
  }

  /// Extracts the name from an encoded string.
  ///
  /// Supported encoding scheme:
  /// <Location-name>---<Wall-name>[-thumbnail].<jpg|png>
  static String getEncodedName(String encodedName) {
    String name = "";

    if (encodedName.contains('---')) {
      List<String> splitPrimary = encodedName.split('---');
      if (splitPrimary[1].contains('-thumbnail')) {
        int indexOfThumbnailSeparator = splitPrimary[1].indexOf('-');
        name = splitPrimary[1].substring(0, indexOfThumbnailSeparator);
      } else {
        int indexOfFileEnding = splitPrimary[1].indexOf('.');
        name = splitPrimary[1].substring(0, indexOfFileEnding);
      }
    } else {
      name = basename(encodedName);
    }

    return name;
  }
}