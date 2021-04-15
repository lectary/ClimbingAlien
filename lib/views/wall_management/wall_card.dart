import 'package:cached_network_image/cached_network_image.dart';
import 'package:climbing_alien/data/api/climbr_api.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/utils/dialogs.dart';
import 'package:climbing_alien/viewmodels/wall_viewmodel.dart';
import 'package:climbing_alien/views/route_management/route_screen.dart';
import 'package:climbing_alien/views/wall_management/image_preview.dart';
import 'package:climbing_alien/views/wall_management/wall_form.dart';
import 'package:climbing_alien/widgets/image_display.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

/// Class representing a single carousel wall entry in the location list.
class WallCard extends StatelessWidget {
  final Wall wall;
  final bool isExpanded;

  WallCard(this.wall, this.isExpanded);

  @override
  Widget build(BuildContext context) {
    final wallModel = Provider.of<WallViewModel>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: GestureDetector(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildHeader(context, wallModel),
            _buildBody(context),
          ]),
          onTap: () async {
            wallModel.selectedWall = wall;
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(value: wallModel, child: RouteScreen())));
            wallModel.selectedWall = null;
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WallViewModel wallViewModel) {
    return Container(
      color: Colors.grey[300],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Structure: Row1[ Row2[Left side with title] <- space-between -> Row3[Right side with actions]]
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildWallStatusIcon(context, wall.status),
                    ),
                    Text(wall.title, style: Theme.of(context).textTheme.headline5),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.remove_red_eye_outlined),
                        onPressed: () => WallImagePreview.asDialog(context, wall)),
                    ...wall.isCustom
                        ? [
                            IconButton(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                icon: Icon(Icons.edit),
                                onPressed: () => WallForm.showWallFormDialog(context, wall: wall)),
                            IconButton(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  bool canDeleteWithoutConflicts = await wallViewModel.deleteWall(wall);
                                  if (!canDeleteWithoutConflicts) {
                                    await Dialogs.showAlertDialog(
                                        context: context,
                                        title:
                                            'Diese Wand hat bereits Routen gespeichert! Wenn Sie die Wand löschen, werden auch alle Routen gelöscht!',
                                        submitText: 'Löschen',
                                        submitFunc: () => wallViewModel.deleteWall(wall, cascade: true));
                                  }
                                })
                          ]
                        : []
                  ],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: FutureBuilder(
                  future: wallViewModel.getNumberOfRoutesByWall(wall),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text("${snapshot.data!} Routes");
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }

  /// TODO remove maybe - primarily build for testing purpose
  Widget _buildWallStatusIcon(BuildContext context, WallStatus status) {
    switch (status) {
      case WallStatus.notPersisted:
        return Icon(Icons.file_download);
      case WallStatus.persisted:
        return Icon(Icons.file_download_done, color: Colors.green);
      case WallStatus.removed:
        return Icon(Icons.remove_circle_outline, color: Colors.red);
      case WallStatus.downloading:
        return CircularProgressIndicator();
      case WallStatus.updateAvailable:
        return Container();
    }
  }


  Widget _buildBody(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AspectRatio(
            aspectRatio: 4 / 3,
            child: wall.status == WallStatus.persisted && wall.filePath != null
                ? ImageDisplay(
                    // TODO create some thumbnail for custom made images for consistent image size
                    // wall.isCustom ? wall.filePath : wall.thumbnailPath,
                    wall.thumbnailPath,
                    emptyText: 'No image found',
                  )
                : (wall.status == WallStatus.downloading
            ? Center(child: CircularProgressIndicator())
            : ( // To reduce network requests, only load/render [Image.network] when the parent panel is indeed expanded
                isExpanded
                    ? CachedNetworkImage(
                  imageUrl: ClimbrApi.urlApiEndpoint + basename(wall.thumbnailName!),
                  progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                      child: CircularProgressIndicator(
                        value: downloadProgress.totalSize != null
                            ? downloadProgress.downloaded / downloadProgress.totalSize!
                            : null,
                      )),
                  errorWidget: (context, url, error) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error),
                      SizedBox(height: 10),
                      Text(
                        "Error loading thumbnail:\n" +
                            (error.toString().contains('404') ? "Not found" : error.toString()),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                )
                    : Container()))),
      ),
    );
  }
}
