import 'dart:io';

import 'package:climbing_alien/viewmodels/image_view_model.dart';
import 'package:climbing_alien/views/climbing_alien_painter.dart';
import 'package:climbing_alien/widgets/camera_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Offset tapPoint;
  List<CustomPaint> painters = [];
  ImageViewModel model;
  int _selectedIndex = 0;
  String backgroundImagePath;

  @override
  Widget build(BuildContext context) {
    backgroundImagePath = context.select((ImageViewModel model) => model.currentImagePath);
    List<Widget> _widgetOptions = [
      _buildPainterWidget(), CameraWidget()
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text("Climbing Alien"),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_reset",
        child: Text("Reset"),
        onPressed: () => setState(() => painters = []),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (tapDownDetails) {
        setState(() {
          tapPoint = tapDownDetails.localPosition;
          final paint = CustomPaint(
            painter: ClimbingAlienPainter(position: tapPoint),
            child: Center(child: Container()),
          );
          painters.add(paint);
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackgroundImage(),
          ...painters,
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return backgroundImagePath == null
    ? Container()
    : FittedBox(fit: BoxFit.fill, child: Image.file(File(backgroundImagePath)));
  }
}
