import 'package:camera/camera.dart';
import 'package:climbing_alien/views/drawer/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../main.dart';
import 'display_image_screen.dart';

class CameraScreen extends StatefulWidget {
  static const routeName = "/camera";

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
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
    // TODO migrate
    String path = join((await getTemporaryDirectory()).path, "${DateTime.now()}.png");
    XFile file = await controller.takePicture();
    Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayImageScreen(file.path)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Camera")),
        drawer: AppDrawer(),
        body: !controller.value.isInitialized
            ? Container()
            : AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: "fab_camera",
          child: Icon(Icons.camera),
          onPressed: () => _takePicture(context),
        ),
        bottomNavigationBar: BottomAppBar(
            color: Theme.of(context).primaryColor,
            child: Container(
                height: kToolbarHeight,
                child: Center(
                    child: Text("Press the Button in the middle to take a photo.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color: Theme.of(context).colorScheme.onPrimary)))))));
  }
}
