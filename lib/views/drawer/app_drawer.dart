import 'package:climbing_alien/views/camera/camera_screen.dart';
import 'package:climbing_alien/views/home_screen.dart';
import 'package:flutter/material.dart';

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
                    title: Text("Route editing"),
                    onTap: () {
                      Navigator.pop(context);
                      return Navigator.pushNamed(context, HomeScreen.routeName);
                    }),
                ListTile(
                    title: Text("Camera"),
                    onTap: () {
                      Navigator.pop(context);
                      return Navigator.pushNamed(context, CameraScreen.routeName);
                    }),
                ListTile(title: Text("Image management"), onTap: () => {}),
              ],
            ),
          )
        ],
      ),
    );
  }
}
