import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/viewmodels/wall_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WallImageDownloader extends StatefulWidget {
  final Wall wall;

  WallImageDownloader(this.wall);

  static Future<bool?> asDialog(BuildContext context, Wall wall) async {
    final model = Provider.of<WallViewModel>(context, listen: false);
    return await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (context) => ChangeNotifierProvider.value(
              value: model,
              child: AlertDialog(
                title: Text("Image Downloader"),
                content: WallImageDownloader(wall),
                actions: [
                  ElevatedButton(
                      onPressed: () async {
                        await model.cancelWallImageDownload();
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Theme.of(context).colorScheme.onError),
                      ),
                      style: ElevatedButton.styleFrom(primary: Theme.of(context).colorScheme.error))
                ],
              ),
            ));
  }

  @override
  _WallImageDownloaderState createState() => _WallImageDownloaderState();
}

class _WallImageDownloaderState extends State<WallImageDownloader> {
  late final WallViewModel wallModel;

  @override
  void initState() {
    super.initState();
    wallModel = Provider.of<WallViewModel>(context, listen: false);
    WidgetsBinding.instance?.addPostFrameCallback((_) => wallModel.downloadWallImage(widget.wall));
  }

  @override
  Widget build(BuildContext context) {
    return Selector<WallViewModel, double?>(
      selector: (context, model) => model.downloadProgress,
      builder: (context, progress, child) {
        if (progress == -1) {
          WidgetsBinding.instance?.addPostFrameCallback((_) => Navigator.pop(context));
          wallModel.downloadProgress = null;
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Before you can start editing your route, we first need the wall image from the server!\n'
                'Downloading image for wall "${widget.wall.title}". '
                'Please wait...'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicatorWithNumber(progress),
            ),
          ],
        );
      },
    );
  }
}

class CircularProgressIndicatorWithNumber extends StatelessWidget {
  final double? progress;

  final double _indicatorSize = 48;

  CircularProgressIndicatorWithNumber(this.progress);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      LinearProgressIndicator(value: progress,),
      // Container(height: _indicatorSize, width: _indicatorSize, child: CircularProgressIndicator(value: progress)),
      (progress == null || progress! == -1 ) ? Container() : Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: Text("${_getPercentage(progress!)} %"),
      )
    ]);
  }

  String _getPercentage(double progress) {
    return (progress * 100).floor().toString();
  }
}
