import 'dart:io';

import 'package:climbing_alien/viewmodels/image_view_model.dart';
import 'package:climbing_alien/widgets/camera_widget.dart';
import 'package:climbing_alien/widgets/climax/climax.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/";

  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ImageViewModel model;
  int _selectedWidgetIndex = 0;
  String backgroundImagePath;

  Offset climaxPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    climaxPosition = Offset(size.width / 2, size.height / 2 - kToolbarHeight);

    backgroundImagePath = context.select((ImageViewModel model) => model.currentImagePath);
    List<Widget> _widgetOptions = [
      _buildPainterWidget(), CameraWidget()
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text("Climbing Alien"),
      ),
      body: _widgetOptions.elementAt(_selectedWidgetIndex),
      // floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      // floatingActionButton: FloatingActionButton(
      //   heroTag: "fab_reset",
      //   child: Text("Reset"),
      //   onPressed: () => setState(() => painters = []),
      // ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedWidgetIndex,
        onTap: (index) => setState(() => _selectedWidgetIndex = index),
        items: [
          BottomNavigationBarItem(
            label: "Painter",
            icon: Icon(Icons.format_paint),
          ),
          BottomNavigationBarItem(
              label: "Camera", icon: Icon(Icons.camera_alt_outlined)),
        ],
      ),
    );
  }

  Widget _buildPainterWidget() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackgroundImage(),
        Climax(
          position: climaxPosition,
        ),
      ],
    );
  }

  Widget _buildBackgroundImage() {
    return backgroundImagePath == null
    ? Container()
    : FittedBox(fit: BoxFit.fill, child: Image.file(File(backgroundImagePath)));
  }
}
