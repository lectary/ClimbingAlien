import 'package:climbing_alien/data/api/climbr_api.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/utils/dialogs.dart';
import 'package:climbing_alien/viewmodels/wall_viewmodel.dart';
import 'package:climbing_alien/views/route_management/route_screen.dart';
import 'package:climbing_alien/views/route_management/wall_form.dart';
import 'package:climbing_alien/widgets/image_display.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            /// Header
            Container(
              color: Colors.grey[300],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(wall.title, style: Theme.of(context).textTheme.headline5),
                        Row(
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
                                  bool canDeleteWithoutConflicts = await wallModel.deleteWall(wall);
                                  if (!canDeleteWithoutConflicts) {
                                    await Dialogs.showAlertDialog(
                                        context: context,
                                        title:
                                            'Diese Wand hat bereits Routen gespeichert! Wenn Sie die Wand löschen, werden auch alle Routen gelöscht!',
                                        submitText: 'Löschen',
                                        submitFunc: () => wallModel.deleteWall(wall, cascade: true));
                                  }
                                })
                          ],
                        )
                      ],
                    ),
                    Text(wall.description ?? ""),
                  ],
                ),
              ),
            ),

            /// Wall image
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: !wall.isCustom
                      // To reduce network requests, only load/render [Image.network] when the parent panel is indeed expanded
                      ? (isExpanded
                          ? Image.network(
                              ClimbrApi.apiUrl + wall.file!,
                              loadingBuilder: (context, child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  print("Loading ${wall.file}");
                                  return child;
                                }
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            )
                          : Container())
                      : ImageDisplay(
                          wall.file,
                          emptyText: 'No image',
                        ),
                ),
              ),
            )
          ]),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RouteScreen(wall))),
        ),
      ),
    );
  }
}
