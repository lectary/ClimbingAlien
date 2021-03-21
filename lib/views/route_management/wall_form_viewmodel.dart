import 'dart:async';

import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:flutter/material.dart';

class WallFormViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;
  StreamSubscription<List<Wall>> _wallStreamSubscription;

  WallFormViewModel({@required ClimbingRepository climbingRepository})
      : assert(climbingRepository != null),
        _climbingRepository = climbingRepository {
    print("WallFormViewModel created");
    _wallStreamSubscription = _climbingRepository.watchAllWalls().listen(wallStreamListener);
  }

  @override
  void dispose() {
    super.dispose();
    _wallStreamSubscription.cancel();
  }

  void wallStreamListener(List<Wall> wallList) {
    walls = wallList.where((Wall wall) => wall.location != null && wall.location.isNotEmpty).toList();
    suggestions = walls.map((e) => e.location).toList();
  }

  List<Wall> walls;

  List<String> _suggestions = List.empty();

  List<String> get suggestions => _suggestions;

  set suggestions(List<String> suggestions) {
    _suggestions = suggestions;
    notifyListeners();
  }

  getSuggestionsByString(String string) {
    if (walls == null || walls.isEmpty) return;
    final newList =
        walls.where((Wall wall) => wall.location.contains(string)).map((Wall wall) => wall.location).toList();
    suggestions = List.from(newList);
  }
}
