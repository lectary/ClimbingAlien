import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const DEFAULT_CLIMAX_COLOR = Colors.amber;
  static const DEFAULT_GHOSTING_COLOR = Colors.grey;
  static const DEFAULT_SELECTION_COLOR = Colors.red;

  static const _KEY_PREFS_CLIMAX_COLOR = "climax_color";
  static const _KEY_PREFS_GHOSTING_COLOR = "ghosting_color";
  static const _KEY_PREFS_SELECTION_COLOR = "selection_color";

  /// Setter/Getter for color of climax itself.
  static Future<bool> saveClimaxColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(_KEY_PREFS_CLIMAX_COLOR, color.value);
  }

  static Future<Color> getClimaxColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_KEY_PREFS_CLIMAX_COLOR);
    return colorValue == null ? DEFAULT_CLIMAX_COLOR : Color(colorValue);
  }

  /// Setter/Getter for color of climax ghost limbs.
  static void saveGhostingColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_KEY_PREFS_GHOSTING_COLOR, color.value);
  }

  static Future<Color> getGhostingColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_KEY_PREFS_GHOSTING_COLOR);
    return colorValue == null ? DEFAULT_GHOSTING_COLOR : Color(colorValue);
  }

  /// Setter/Getter for color of climax limb selection.
  static void saveSelectionColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_KEY_PREFS_SELECTION_COLOR, color.value);
  }

  static Future<Color> getSelectionColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_KEY_PREFS_SELECTION_COLOR);
    return colorValue == null ? DEFAULT_SELECTION_COLOR : Color(colorValue);
  }
}