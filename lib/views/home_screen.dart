import 'dart:async';
import 'dart:io';

import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/viewmodels/image_view_model.dart';
import 'package:climbing_alien/widgets/camera_widget.dart';
import 'package:climbing_alien/widgets/climax/climax.dart';
import 'package:climbing_alien/widgets/controls/joystick_control.dart';
import 'package:climbing_alien/widgets/header_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  Offset screenCenter;
  Timer timer;
  final int refreshTime = 60;

  @override
  void initState() {
    super.initState();
    climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
    // Updating climax default position after finishing widget build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      screenCenter = Offset(size.width / 2.0, size.height / 2.0 - kToolbarHeight * 2);
      climaxModel.updateClimaxPosition(screenCenter);
    });
    // Using timer for continuously drawing climax to enable continuous movement via joystick
    timer = Timer.periodic(Duration(milliseconds: refreshTime), (Timer t) => climaxModel.updateLimbFree());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
        onPressed: () => climaxModel.resetClimax(position: screenCenter),
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
                    setState(() {
                      climaxModel.updateSelectedLimbPosition(offset);
                    });
                  },
                  child: Climax()),
              Positioned(
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: JoystickWithControlButtons(
                      onDirectionChanged: (degrees, distance) {
                        climaxModel.moveLimbFree(degrees, distance);
                      },
                      onSliderChanged: (speed) => climaxModel.updateSpeed(speed),
                      onClickedUp: () => climaxModel.moveLimbDirectional(Direction.UP),
                      onClickedDown: () => climaxModel.moveLimbDirectional(Direction.DOWN),
                      onClickedLeft: () => climaxModel.moveLimbDirectional(Direction.LEFT),
                      onClickedRight: () => climaxModel.moveLimbDirectional(Direction.RIGHT),
                    ),
                  )),
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
