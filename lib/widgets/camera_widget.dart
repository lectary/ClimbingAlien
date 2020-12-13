import 'package:camera/camera.dart';
import 'package:climbing_alien/main.dart';
import 'package:climbing_alien/views/camera/display_image_screen.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CameraWidget extends StatefulWidget {
  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _takePicture(BuildContext context) async {
    if (!controller.value.isInitialized) return;
    String path =
        join((await getTemporaryDirectory()).path, "${DateTime.now()}.png");
    await controller.takePicture(path);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DisplayImageScreen(path)));
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: Stack(
        children: [
          CameraPreview(controller),
          Positioned(
            right: 32,
            bottom: 32,
            child: FloatingActionButton(
              heroTag: "fab_camera",
              child: Icon(Icons.camera),
              onPressed: () => _takePicture(context),
            ),
          )
        ],
      ),
    );
  }
}
