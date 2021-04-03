import 'package:climbing_alien/views/camera/camera_screen.dart';
import 'package:climbing_alien/views/route_editor/route_editor_screen.dart';
import 'package:climbing_alien/views/wall_management/wall_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(child: Center(child: Text("Hello Climax"))),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                    title: Text("Route management"), onTap: () => Navigator.pushNamed(context, WallScreen.routeName)),
                ListTile(
                    title: Text("Route editing"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, RouteEditorScreen.routeName);
                    }),
                ListTile(
                    title: Text("Camera"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, CameraScreen.routeName);
                    }),
                ListTile(title: Text("Image management"), onTap: () => Fluttertoast.showToast(msg: "Coming soon!")),
              ],
            ),
          )
        ],
      ),
    );
  }
}
