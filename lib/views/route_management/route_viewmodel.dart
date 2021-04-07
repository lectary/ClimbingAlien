import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:climbing_alien/data/api/climbr_api.dart';
import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class RouteViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;

  Wall? wall;
  List<Route> routeList = List.empty();

  StreamController<List<Route>> routeStreamController = StreamController<List<Route>>();

  Stream<List<Route>> get routeStream => routeStreamController.stream;
  StreamSubscription<List<Route>>? routeStreamSubscription;

  RouteViewModel({required ClimbingRepository climbingRepository, this.wall})
      : _climbingRepository = climbingRepository {
    loadRoutesByWall(wall);
  }

  @override
  void dispose() {
    routeStreamController.close();
    routeStreamSubscription?.cancel();
    super.dispose();
  }

  void loadRoutesByWall(Wall? wall) async {
    if (wall == null) return;
    if (wall.id == null) {
      routeStreamController.sink.add([]);
    } else {
      routeStreamSubscription?.cancel();
      routeStreamSubscription = _climbingRepository.watchAllRoutesByWallId(wall.id!).listen((event) {
        print("new route list");
        if (!routeStreamController.isClosed) {
          routeStreamController.sink.add(event);
        }
      });
    }
  }

  Future<void> insertRoute(Route route) {
    return _climbingRepository.insertRoute(route);
  }

  Future<void> updateRoute(Route route) {
    return _climbingRepository.updateRoute(route);
  }

  Future<bool> deleteRoute(Route route, {bool forceDelete = false}) async {
    // Check whether route's wall has still other routes
    List<Route> routesOfWall = await _climbingRepository.findAllRoutesByWallId(route.wallId);
    routesOfWall.remove(route);
    if (routesOfWall.isEmpty) {
      if (!forceDelete) {
        return true;
      }
      await _deleteRoute(route);
      // TODO simplify by dedicated db-query
      // Delete locally persisted wall if it has no routes
      Wall emptyWallToDelete = await _climbingRepository
          .fetchAllWalls()
          .then((List<Wall> wallList) => wallList.firstWhere((Wall wall) => wall.id == route.wallId));
      log("Delete empty wall ${emptyWallToDelete.title}");
      await StorageService.deleteFromDevice(emptyWallToDelete.filePath);
      await StorageService.deleteFromDevice(emptyWallToDelete.thumbnailPath);
      await _climbingRepository.deleteWall(emptyWallToDelete);
    } else {
      await _deleteRoute(route);
    }

    return false;
  }

  Future<void> _deleteRoute(Route route) async {
    log("Delete route ${route.title}");
    // Deletes all grasps from route first
    List<Grasp> graspByRoute = await _climbingRepository.findAllGraspsByRouteId(route.id!);
    await Future.forEach(graspByRoute, (Grasp grasp) => _climbingRepository.deleteGrasp(grasp));
    await _climbingRepository.deleteRoute(route);
  }

  Future<void> insertRouteWithWall(Route route, Wall wall) async {
    // TODO download wall image file
    wall.status = WallStatus.downloading;

    File fileThumbnail = await _climbingRepository.downloadFile(wall.thumbnailName!);
    String newPathThumbnail = await StorageService.saveToDevice(fileThumbnail.path);
    wall.thumbnailPath = newPathThumbnail;

    File file = await _climbingRepository.downloadFile(wall.fileName!);
    String newPath = await StorageService.saveToDevice(file.path);
    wall.filePath = newPath;

    int newWallId = await _climbingRepository.insertWall(wall);

    await _climbingRepository.insertRoute(route..wallId = newWallId);
    loadRoutesByWall(wall..id = newWallId);
  }

  /// Grasps
  Stream<List<Grasp>> getGraspStreamByRouteId(int routeId) => _climbingRepository.watchAllGraspsByRouteId(routeId);
}
