import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/viewmodels/wall_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';


class WallImageDownloader extends StatefulWidget {
  final Wall wall;

  WallImageDownloader(this.wall);

  static Future<Tuple2<bool, Exception?>?> asDialog(BuildContext context, Wall wall) async {
    final model = Provider.of<WallViewModel>(context, listen: false);
    return await showDialog<Tuple2<bool, Exception?>>(
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
                        _navigatorPop(context);
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
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      try {
        await wallModel.downloadWallImage(widget.wall);
      } on Exception catch (e) {
        _navigatorPop(context, error: e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<WallViewModel, double?>(
      selector: (context, model) => model.downloadProgress,
      builder: (context, progress, child) {
        if (progress == -1) {
          WidgetsBinding.instance?.addPostFrameCallback((_) => _navigatorPop(context));
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

  final double _indicatorHeight = 48;

  CircularProgressIndicatorWithNumber(this.progress);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _indicatorHeight,
      child: Stack(alignment: Alignment.center, children: [
        LinearProgressIndicator(
          value: progress,
        ),
        (progress == null || progress! == -1)
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: Text("${_getPercentage(progress!)} %"),
              )
      ]),
    );
  }

  String _getPercentage(double progress) {
    return (progress * 100).floor().toString();
  }
}

void _navigatorPop(BuildContext context, {Exception? error}) {
  if (error != null) {
    Navigator.pop(context, Tuple2(false, error));
  } else {
    Navigator.pop(context, Tuple2(true, null));
  }
}
