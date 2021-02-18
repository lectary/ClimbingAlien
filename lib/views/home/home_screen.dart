import 'dart:async';
import 'dart:io';

import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/viewmodels/image_viewmodel.dart';
import 'package:climbing_alien/views/drawer/app_drawer.dart';
import 'package:climbing_alien/views/home/route_editor.dart';
import 'package:climbing_alien/widgets/climax/climax.dart';
import 'package:climbing_alien/widgets/controls/joystick_extended.dart';
import 'package:climbing_alien/widgets/header_control/header_control.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

// Used for switching between different route editors
class HomeScreenRouteArguments {
  final int routeEditorPrototype;

  HomeScreenRouteArguments(this.routeEditorPrototype);
}

class HomeScreen extends StatefulWidget {
  static const routeName = "/";

  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ImageViewModel model;
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
      screenCenter = Offset(size.width / 2.0, size.height / 2.0 - kToolbarHeight);
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
    final HomeScreenRouteArguments args = ModalRoute.of(context).settings.arguments;

    backgroundImagePath = context.select((ImageViewModel model) => model.currentImagePath);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: HeaderControl(
          _getRouteEditorTitle(args?.routeEditorPrototype ?? 1),
          nextSelectionCallback: climaxModel.selectNextLimb,
          resetCallback: () => climaxModel.resetClimax(position: screenCenter),
        ),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _getRouteEditorPrototype(args?.routeEditorPrototype ?? 1),
                Positioned(
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32.0),
                      child: JoystickWithButtonAndSlider(
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
      ),
    );
  }

  Widget _getRouteEditorPrototype(int routeEditorPrototype) {
    switch (routeEditorPrototype) {
      case 1:
        return RouteEditor();
      case 2:
        return RouteEditor2();
      case 3:
        return RouteEditor3();
      case 4:
        return RouteEditor4();
    }
  }

  String _getRouteEditorTitle(int routeEditorPrototype) {
    switch (routeEditorPrototype) {
      case 1:
        return "RouteEditor 1";
      case 2:
        return "RouteEditor 2";
      case 3:
        return "RouteEditor 3";
      case 4:
        return "RouteEditor 4";
    }
  }
}
