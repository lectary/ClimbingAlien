import 'dart:io';

import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/viewmodels/image_view_model.dart';
import 'package:climbing_alien/widgets/camera_widget.dart';
import 'package:climbing_alien/widgets/climax/climax.dart';
import 'package:climbing_alien/widgets/header_control.dart';
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
  ClimaxViewModel climaxModel;

  @override
  void initState() {
    super.initState();
    climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    backgroundImagePath = context.select((ImageViewModel model) => model.currentImagePath);
    List<Widget> _widgetOptions = [_buildPainterWidget(context), CameraWidget()];
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedWidgetIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_reset",
        child: Text("Reset"),
        onPressed: () => climaxModel.resetClimax(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedWidgetIndex,
        onTap: (index) => setState(() => _selectedWidgetIndex = index),
        items: [
          BottomNavigationBarItem(
            label: "Painter",
            icon: Icon(Icons.format_paint),
          ),
          BottomNavigationBarItem(label: "Camera", icon: Icon(Icons.camera_alt_outlined)),
        ],
      ),
    );
  }

  Widget _buildPainterWidget(BuildContext context) {
    return Column(
      children: [
        HeaderControl(climaxModel.selectNextLimb),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackgroundImage(),
              GestureDetector(
                  onTapDown: (details) {
                    RenderBox box = context.findRenderObject();
                    final offset = box.localToGlobal(details.localPosition);
                    print(offset);
                    setState(() {
                      if (climaxModel.selectedLimb == ClimaxLimbEnum.BODY) {
                        climaxModel.updateClimaxPosition(offset);
                      }
                    });
                  },
                  child: Climax()),
              Positioned(
                right: 0,
                bottom: 0,
                child: Column(
                  children: [
                    RaisedButton(
                      onPressed: () => climaxModel.moveSelectedLimb(Direction.RIGHT),
                      child: Text("Move limb Right"),
                    ),
                    RaisedButton(
                      onPressed: () => climaxModel.moveSelectedLimb(Direction.LEFT),
                      child: Text("Move limb Left"),
                    ),
                    RaisedButton(
                      onPressed: () => climaxModel.moveSelectedLimb(Direction.UP),
                      child: Text("Move limb up"),
                    ),
                    RaisedButton(
                      onPressed: () => climaxModel.moveSelectedLimb(Direction.DOWN),
                      child: Text("Move limb down"),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
