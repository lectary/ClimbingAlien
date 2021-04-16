import 'package:cached_network_image/cached_network_image.dart';
import 'package:climbing_alien/data/api/climbr_api.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/utils/utils.dart';
import 'package:climbing_alien/widgets/image_display.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class WallImagePreview extends StatelessWidget {
  final Wall wall;

  WallImagePreview(this.wall);

  static Future<void> asDialog(BuildContext context, Wall wall) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(wall.fileName == null ? 'No image found' : "Preview of " + Utils.getEncodedName(wall.fileName!)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(child: Scrollbar(isAlwaysShown: true, child: SingleChildScrollView(child: WallImagePreview(wall)))),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Abbrechen",
                  style: TextStyle(color: Theme.of(context).colorScheme.onError),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).colorScheme.error,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (wall.status == WallStatus.persisted) {
      return ImageDisplay(wall.filePath);
    } else {
      return CachedNetworkImage(
        imageUrl: ClimbrApi.urlApiEndpoint + basename(wall.fileName!),
        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
            child: CircularProgressIndicator(
              value: downloadProgress.totalSize != null ? downloadProgress.downloaded / downloadProgress.totalSize! : null,
            )),
        errorWidget: (context, url, error) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error),
            SizedBox(height: 10),
            Text(
              "Error loading thumbnail:\n" + (error.toString().contains('404') ? "Not found" : error.toString()),
              textAlign: TextAlign.center,
            )
          ],
        ),
      );
    }
  }
}
