import 'package:cached_network_image/cached_network_image.dart';
import 'package:climbing_alien/data/api/climbr_api.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/utils/dialogs.dart';
import 'package:climbing_alien/viewmodels/wall_viewmodel.dart';
import 'package:climbing_alien/views/route_management/route_screen.dart';
import 'package:climbing_alien/views/wall_management/wall_form.dart';
import 'package:climbing_alien/widgets/image_display.dart';
import 'package:flutter/material.dart';
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
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RouteScreen(wall))),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(wall.title, style: Theme.of(context).textTheme.headline5),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
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
                wall.isCustom
                    ? Row(
                        children: [
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
                        ],
                      )
                    : Container()
              ],
            ),
            Text(wall.description ?? ""),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: !wall.isCustom
              // To reduce network requests, only load/render [Image.network] when the parent panel is indeed expanded
              ? (isExpanded
                  ? CachedNetworkImage(
                      imageUrl: ClimbrApi.apiUrl + wall.file!,
                      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                          child: CircularProgressIndicator(
                        value: downloadProgress.totalSize != null
                            ? downloadProgress.downloaded / downloadProgress.totalSize!
                            : null,
                      )),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )
                  : Container())
              : ImageDisplay(
                  wall.file,
                  emptyText: 'No image',
                ),
        ),
      ),
    );
  }
}
