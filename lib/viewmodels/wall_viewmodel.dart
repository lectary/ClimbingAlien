import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/model/location.dart';
import 'package:climbing_alien/model/model_state.dart';
import 'package:climbing_alien/services/storage_service.dart';
import 'package:climbing_alien/utils/exceptions/internet_exception.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as image;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// ViewModel for [Wall] management, selection and interactions with the ClimbrApi server.
///
/// Uses [ModelState] for operations with the api server (e.g. [loadAllWalls]) to handle the async state.
class WallViewModel extends ChangeNotifier {
  final ClimbingRepository _climbingRepository;

  ModelState _modelState = ModelState.completed();

  ModelState get modelState => _modelState;

  set modelState(ModelState modelState) {
    _modelState = modelState;
    notifyListeners();
  }

  List<Location> locationList = List.empty();
  List<Wall> _wallList = List.empty();
  Wall? selectedWall;

  bool _offlineMode = false;
  bool get offlineMode => _offlineMode;

  WallViewModel({required ClimbingRepository climbingRepository}) : _climbingRepository = climbingRepository {
    log("Created WallViewModel");
    loadAllWalls();
    listenToLocalWalls();
  }

  late StreamSubscription<List<Wall>> _wallStreamSubscription;

  /// Starts a [StreamSubscription] on the list of persisted [Wall].
  /// Updates [_wallList] and [locationList] when new values are yielded.
  listenToLocalWalls() {
    _wallStreamSubscription = _climbingRepository.watchAllWalls().listen((wallList) {
      updateCachedWallsAndLocations(wallList);
    });
  }

  @override
  void dispose() {
    _wallStreamSubscription.cancel();
    super.dispose();
  }

  /// Updates the locally cached location and wall list with the passed wall list.
  void updateCachedWallsAndLocations(List<Wall> newLocalList) {
    _wallList = _mergeWalls(localWalls: newLocalList, remoteWalls: _wallList);
    locationList = groupWalls(_wallList);
    _sortLocationsAndWalls(locationList);

    // Update wall selection
    if (selectedWall != null /*  && selectedWall!.status == WallStatus.notPersisted */) {
      Wall? wall = _wallList.firstWhereOrNull(
          (element) => element.title == selectedWall!.title && element.location == selectedWall!.location);
      if (wall != null) {
        selectedWall = wall;
      }
    }

    notifyListeners();
  }

  /// Function for loading all walls, local and remote ones.
  /// While loading, [modelState] is [ModelState.loading] with a loading message.
  /// On success, [locationList] is updated and [modelState] is set to [ModelState.completed].
  /// If an error occurs, [modelState] will be set to [ModelState.error] with an appropriate error message.
  Future<void> loadAllWalls() async {
    modelState = ModelState.loading("Loading walls from server...");

    try {
      final localWalls = await _climbingRepository.fetchAllWalls();

      try {
        List<Wall> remoteWalls = await _climbingRepository.fetchAllWallsFromApi();
        _wallList = _mergeWalls(localWalls: localWalls, remoteWalls: remoteWalls);
        _offlineMode = false;
      } on InternetException {
        log("No internet!");
        _wallList = _mergeWalls(localWalls: localWalls, remoteWalls: []);
        _offlineMode = true;
      }

      locationList = groupWalls(_wallList);

      _sortLocationsAndWalls(locationList);

      modelState = ModelState.completed();
    } catch (e) {
      modelState = ModelState.error("Error loading walls from server:\n$e");
    }
  }

  void _sortLocationsAndWalls(List<Location> locations) {
    locationList.forEach((location) => location.walls.sort((wall1, wall2) => wall1.title.compareTo(wall2.title)));
    locationList.sort((loc1, loc2) => loc1.name.compareTo(loc2.name));
  }

  /// Group walls by [Wall.location].
  /// Returns a list of [Location].
  List<Location> groupWalls(List<Wall> wallList) {
    return groupBy(wallList, (Wall wall) => wall.location)
        .entries
        .map((MapEntry<String?, List<Wall>> entry) =>
            Location(entry.key ?? "<no-name>", entry.value..sort((w1, w2) => w1.title.compareTo(w2.title))))
        .toList();
  }

  /// Merges two lists of [Wall].
  /// This function can handle the case, that [remoteWalls] is a previous merged list (the result of this function).
  /// Returns a list of [Wall].
  List<Wall> _mergeWalls({required List<Wall> localWalls, required List<Wall> remoteWalls}) {
    List<Wall> resultList = [];

    // Comparing local with remote list and adding all local persisted lectures to the result list
    localWalls.forEach((local) {
      remoteWalls.forEach((remote) {
        if (local.location == remote.location && local.title == remote.title) {
          resultList.add(local..status = WallStatus.persisted);
        }
      });
    });

    // Check if any local walls are outdated (i.e. not available remotely anymore)
    localWalls.forEach((local) {
      // If its a custom wall, add it to list, otherwise its a copy from a remote wall, and then it may be deleted
      if (remoteWalls.any((remote) => local.location == remote.location && local.title == remote.title) == false) {
        if (local.isCustom) {
          resultList.add(local..status = WallStatus.persisted);
        } else {
          // TODO remove wall and its children automatically or provide a user option
          resultList.add(local..status = WallStatus.removed);
        }
      }
    });

    // Add all remaining and not persisted walls available remotely
    remoteWalls.forEach((remote) {
      if (localWalls.any((local) => remote.location == local.location && remote.title == local.title) == false) {
        // If wall is a custom one, this indicates, that the passed remoteList was a previous merged list,
        // therefore remove this entry from the result, since it got already added in the loop before.
        if (remote.isCustom) {
          resultList.remove(remote);
        } else if (remote.status != WallStatus.removed) {
          // Update id to null, if wall was previously persisted and then deleted
          if (remote.id != null) {
            remote.id = null;
            remote.filePath = null;
            remote.thumbnailPath = null;
          }
          resultList.add(remote..status = WallStatus.notPersisted);
        }
      }
    });

    return resultList;
  }

  Future<int> insertWall(Wall wall) async {
    log("Insert wall with name: " + wall.title.toString());

    // Check whether image has to be saved locally
    if (wall.filePathUpdated != null) {
      // Create and save thumbnail from selected image
      String thumbnailPath = await _createThumbnailFromImage(wall.filePathUpdated!);
      String? newPathThumbnail = await StorageService.saveToDevice(thumbnailPath);
      wall.thumbnailName = basename(newPathThumbnail);
      wall.thumbnailPath = newPathThumbnail;

      // Save selected image to app storage
      String? newPath = await StorageService.saveToDevice(wall.filePathUpdated!);
      wall.fileName = basename(newPath);
      wall.filePath = newPath;
    }

    return _climbingRepository.insertWall(wall);
  }

  Future<void> updateWall(Wall wall) async {
    log("Update wall with name: " + wall.title.toString());

    // Check whether image has to be updated locally
    if (basename(wall.filePath ?? "") != basename(wall.filePathUpdated ?? "")) {
      // Delete old thumbnail, and create and save new one
      await StorageService.deleteFromDevice(wall.thumbnailPath);
      String thumbnailPath = await _createThumbnailFromImage(wall.filePathUpdated!);
      String? newPathThumbnail = await StorageService.saveToDevice(thumbnailPath);
      wall.thumbnailName = basename(newPathThumbnail);
      wall.thumbnailPath = newPathThumbnail;

      // Delete old image, and save new one
      await StorageService.deleteFromDevice(wall.filePath);
      String? newPath = await StorageService.saveToDevice(wall.filePathUpdated!);
      wall.fileName = basename(newPath);
      wall.filePath = newPath;
    }

    return _climbingRepository.updateWall(wall);
  }

  Future<bool> deleteWall(Wall wall, {bool cascade = false}) async {
    log("Delete wall with name: " + wall.title.toString());

    // Delete thumbnail and image if available
    await StorageService.deleteFromDevice(wall.thumbnailPath);
    await StorageService.deleteFromDevice(wall.filePath);

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

  Future<int> getNumberOfRoutesByWall(Wall wall) async {
    if (wall.id == null) {
      return Future.value(0);
    }
    return await _climbingRepository.findAllRoutesByWallId(wall.id!).then((value) => value.length);
  }

  /// Creates a thumbnail 300x300 from the provided [Image] accessible via its [imagePath].
  /// The thumbnail will be created from the center 300x300 rectangle.
  /// Returns the filePath of the cached [Image].
  Future<String> _createThumbnailFromImage(String imagePath) async {
    String newPath = "";

    File imageFile = File(imagePath);

    image.Image? srcImage = image.decodeImage(imageFile.readAsBytesSync());
    image.Image? newImage;
    if (srcImage != null) {
      int imageCenterX = srcImage.width ~/ 2;
      int imageCenterY = srcImage.height ~/ 2;
      newImage = image.copyCrop(srcImage, imageCenterX - 150, imageCenterY - 150, 300, 300);

      String fileExtension = extension(imagePath);
      String fileName =
          basename(imagePath).substring(0, basename(imagePath).lastIndexOf('.')) + '-thumbnail' + fileExtension;

      String dirPath = (await getTemporaryDirectory()).path;
      File outFile = File('$dirPath/$fileName');
      if (fileExtension.contains('jpg')) {
        await outFile.writeAsBytes(image.encodeJpg(newImage));
      } else if (fileExtension.contains('png')) {
        await outFile.writeAsBytes(image.encodePng(newImage));
      }
      newPath = outFile.path;
    }

    return newPath;
  }

  /// Variable for the download progress of a walls' image.
  double? _progress;
  double? get downloadProgress => _progress;
  set downloadProgress(double? progress) {
    _progress = progress;
    notifyListeners();
  }
  StreamSubscription<List<int>>? streamSubscriptionWallImageDownload;
  List<int> bytes = [];

  Future<void> cancelWallImageDownload() async {
    selectedWall?.status = WallStatus.persisted;
    downloadProgress = null;
    await streamSubscriptionWallImageDownload?.cancel();
  }

  Future<void> downloadWallImage(Wall wall) async {
    selectedWall?.status = WallStatus.downloading;
    bytes = [];

    downloadProgress = null;

    http.StreamedResponse response;
    try {
      // Download thumbnail
      File fileThumbnail = await _climbingRepository.downloadFile(wall.thumbnailName!);
      String newPathThumbnail = await StorageService.saveToDevice(fileThumbnail.path);
      wall.thumbnailPath = newPathThumbnail;

      // Download highRes image
      response = await _climbingRepository.downloadFileAsStream(wall.fileName!);
    } catch (e) {
      selectedWall?.status = WallStatus.persisted;

      downloadProgress = null;
      throw e;
    }

    final contentLength = response.contentLength ?? 0;
    streamSubscriptionWallImageDownload = response.stream.listen((List<int> newBytes) {
      bytes.addAll(newBytes);
      final downloadedLength = bytes.length;

      downloadProgress = downloadedLength / contentLength;
    }, onDone: () async {
      String newPath = await StorageService.saveBytesToDevice(wall.fileName!, bytes);
      wall.filePath = newPath;

      await _climbingRepository.updateWall(wall);
      selectedWall?.status = WallStatus.persisted;

      downloadProgress = -1;
    }, onError: (e) {
      selectedWall?.status = WallStatus.persisted;
      log("Error downloading file by stream: $e");

      downloadProgress = null;
      throw e;
    }, cancelOnError: true);
  }

}
