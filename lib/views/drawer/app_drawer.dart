import 'package:climbing_alien/views/camera/camera_screen.dart';
import 'package:climbing_alien/views/home/home_screen.dart';
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
                    title: Text("Route editing 1"),
                    onTap: () {
                      Navigator.pop(context);
                      final args = HomeScreenRouteArguments(1);
                      return Navigator.pushNamed(context, HomeScreen.routeName, arguments: args);
                    }),
                ListTile(
                    title: Text("Route editing 2"),
                    onTap: () {
                      Navigator.pop(context);
                      final args = HomeScreenRouteArguments(2);
                      return Navigator.pushNamed(context, HomeScreen.routeName, arguments: args);
                    }),
                ListTile(
                    title: Text("Route editing 3"),
                    onTap: () {
                      Navigator.pop(context);
                      final args = HomeScreenRouteArguments(3);
                      return Navigator.pushNamed(context, HomeScreen.routeName, arguments: args);
                    }),
                ListTile(
                    title: Text("Camera"),
                    onTap: () {
                      Navigator.pop(context);
                      return Navigator.pushNamed(context, CameraScreen.routeName);
                    }),
                ListTile(title: Text("Image management"), onTap: () => Fluttertoast.showToast(msg: "Coming soon!")),
                ListTile(title: Text("Route management"), onTap: () => Fluttertoast.showToast(msg: "Coming soon!")),
              ],
            ),
          )
        ],
      ),
    );
  }
}
