import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/utils/dialogs.dart';
import 'package:climbing_alien/utils/exceptions/internet_exception.dart';
import 'package:climbing_alien/viewmodels/wall_viewmodel.dart';
import 'package:climbing_alien/views/route_editor/route_editor_screen.dart';
import 'package:climbing_alien/views/route_management/route_form.dart';
import 'package:climbing_alien/views/route_management/route_viewmodel.dart';
import 'package:climbing_alien/views/wall_management/wall_image_downloader.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:provider/provider.dart';


/// Screen for [Route] management of a specific [Wall].
///
/// Uses [RouteViewModel] for operating on [Route] models.
class RouteScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final climbingRepository = Provider.of<ClimbingRepository>(context, listen: false);
    return ChangeNotifierProvider(
      create: (context) => RouteViewModel(climbingRepository: climbingRepository, wall: Provider.of<WallViewModel>(context, listen: false).selectedWall),
      child: Consumer<RouteViewModel>(
        builder: (context, routeModel, child) {
          final wall = context.select((WallViewModel model) => model.selectedWall);
          if (wall == null) return Container();
          if (wall.status == WallStatus.persisted && wall.filePath == null) {
            WidgetsBinding.instance?.addPostFrameCallback((_) => _startImageDownloader(context, wall));
          }
          return Scaffold(
          appBar: AppBar(
            title: Text("${wall.title} - Routes"),
          ),
          body: StreamBuilder<List<Route>>(
              stream: routeModel.routeStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final routeList = snapshot.data!;
                  return routeList.isEmpty
                      ? Center(child: Text("No routes available"))
                      : _buildList(context, routeList, routeModel, wall);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => RouteForm.asDialog(context, wall),
          ),
        );
        },
      ),
    );
  }

  _buildList(BuildContext context, List<Route> routeList, RouteViewModel routeModel, Wall wall) {
    return Builder(
      builder: (context) {
        return ListView.builder(
          itemCount: routeList.length,
          itemBuilder: (context, index) {
            final route = routeList[index];
            return ListTile(
              title: Text(route.title),
              subtitle: StreamBuilder<List<Grasp>>(
                  stream: routeModel.getGraspStreamByRouteId(route.id!),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final graspList = snapshot.data!;
                      return Text("${route.description} - ${graspList.length} Grasps");
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => RouteForm.asDialog(context, wall, route: route)),
                  IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async => await Dialogs.showAlertDialog(
                          context: context,
                          title: 'Do you really want to delete this route with all its grasps?',
                          submitText: 'Delete',
                          submitFunc: () async {
                            bool isLastRoute = await routeModel.deleteRoute(route);
                            // TODO re-query status of wall!
                            if (isLastRoute && (wall.status == WallStatus.removed || wall.isCustom)) {
                              await Dialogs.showAlertDialog(
                                  context: context,
                                  // TODO review usability
                                  title: wall.isCustom
                                      ? "If you delete this wall's last route, the wall will be deleted, too!"
                                      : "This wall was removed from the server! If you delete this wall's last route, the wall will not be available anymore!",
                                  submitText: 'Delete',
                                  submitFunc: () => routeModel.deleteRoute(route, forceDelete: true));
                            } else {
                              routeModel.deleteRoute(route, forceDelete: true);
                            }
                          }))
                ],
              ),
              onLongPress: () => RouteForm.asDialog(context, wall, route: route),
              onTap: () async {
                if (wall.filePath == null) {
                  final shallDownload = await Dialogs.showAlertDialog(context: context, title: "Wall Image needed", body: "You need to download the wall image first, before you can edit a route.", submitText: "Download") ?? false;
                  if (shallDownload is bool && shallDownload) {
                    WidgetsBinding.instance?.addPostFrameCallback((_) => _startImageDownloader(context, wall));
                  }
                  return;
                }

                Navigator.push(context, MaterialPageRoute(builder: (context) => RouteEditorScreen(wall, route)));
              },
            );
          });
      },
    );
  }

  _startImageDownloader(BuildContext context, Wall wall) async {
    final result = await WallImageDownloader.asDialog(context, wall);
    if (result != null) {
      if (!result.item1) {
        if (result.item2 is InternetException) {
          Dialogs.showInfoDialog(
            context: context,
            title: "Error downloading Wall Image",
            content: "It seems like you are not connected to the internet. Please check your connection and try again.",
          );
        } else {
          Dialogs.showInfoDialog(
            context: context,
            title: "Error downloading Wall Image",
            content: "During downloading the following error occurred:\n${result.item2}",
          );
        }
      }
    }
  }
}
