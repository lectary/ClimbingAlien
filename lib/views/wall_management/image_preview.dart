import 'package:cached_network_image/cached_network_image.dart';
import 'package:climbing_alien/data/api/climbr_api.dart';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final String imageName;

  ImagePreview(this.imageName);

  static Future<void> asDialog(BuildContext context, String imageName) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Preview of " + imageName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ImagePreview(imageName),
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
    return CachedNetworkImage(
      imageUrl: ClimbrApi.apiUrl + imageName,
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
