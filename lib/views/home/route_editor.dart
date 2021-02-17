import 'dart:io';

import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/viewmodels/image_viewmodel.dart';
import 'package:climbing_alien/views/home/widgets/double_swipe_gesture_detector.dart';
import 'package:climbing_alien/widgets/climax/climax.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


/// Using double swipe is actually not the standard behaviour...(only in special use cases like google maps)...but normally
/// translation is done with one finger....and double swipe for translation conflicts with scaling, which is also done with two fingers....
class RouteEditor extends StatefulWidget {
  @override
  _RouteEditorState createState() => _RouteEditorState();
}

class _RouteEditorState extends State<RouteEditor> {
  ImageViewModel model;
  String backgroundImagePath;
  ClimaxViewModel climaxModel;

  Widget backgroundWidget;
  Image image = Image.asset("assets/images/routes/route1.png");

  @override
  void initState() {
    super.initState();
    climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    backgroundImagePath = context.select((ImageViewModel model) => model.currentImagePath);
    final backgroundSelected = context.select((ClimaxViewModel model) => model.backgroundSelected);
    final scaleBackground = context.select((ClimaxViewModel model) => model.scaleBackground);
    final Offset translate = context.select((ClimaxViewModel model) => model.translate);
    backgroundWidget = Transform.translate(
        offset: translate, child: Transform.scale(scale: scaleBackground, child: image));
    return Stack(fit: StackFit.expand, children: [
      _buildBackgroundImage(),
      DoubleSwipeGestureDetector(
        onUpdate: (DragUpdateDetails details) {
          // print("DoubleSwipe: $details");
          if (backgroundSelected) {
            climaxModel.translate += details.delta;
          }
        },
        child: GestureDetector(
            onScaleStart: (ScaleStartDetails details) {
              if (backgroundSelected) {
                climaxModel.baseScaleBackground = climaxModel.scaleBackground;
              } else {
                climaxModel.baseScaleClimax = climaxModel.scaleClimax;
              }
            },
            onScaleUpdate: (ScaleUpdateDetails details) {
              setState(() {
                print("ScaleUpdate: ${details.scale}");
                if (details.scale == 1) return;
                if (backgroundSelected) {
                  climaxModel.scaleBackground = climaxModel.baseScaleBackground * details.scale;
                } else {
                  climaxModel.scaleClimax = climaxModel.baseScaleClimax * details.scale;
                }
              });
            },
            onTapDown: (details) {
              // RenderBox box = context.findRenderObject();
              // print("Local Offset: ${details.localPosition}");
              // final offset = box.localToGlobal(details.localPosition);
              // print("Global Offset: $offset");
              setState(() {
                if (!backgroundSelected) {
                  climaxModel.updateSelectedLimbPosition(details.localPosition);
                }
              });
            },
            child: Container(color: Colors.transparent, child: Climax())),
      ),
    ]);
  }

  Widget _buildBackgroundImage() {
    return backgroundImagePath == null
        ? backgroundWidget
        : FittedBox(fit: BoxFit.fill, child: Image.file(File(backgroundImagePath)));
  }
}

/// Cannot really detect difference between panning and zooming in a usable way....take too long.
class RouteEditor2 extends StatefulWidget {
  @override
  _RouteEditorState2 createState() => _RouteEditorState2();
}

class _RouteEditorState2 extends State<RouteEditor2> {
  ImageViewModel model;
  String backgroundImagePath;
  ClimaxViewModel climaxModel;

  Widget backgroundWidget;
  Image image = Image.asset("assets/images/routes/route1.png");

  @override
  void initState() {
    super.initState();
    climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    backgroundImagePath = context.select((ImageViewModel model) => model.currentImagePath);
    final backgroundSelected = context.select((ClimaxViewModel model) => model.backgroundSelected);
    final scaleBackground = context.select((ClimaxViewModel model) => model.scaleBackground);
    final Offset translate = context.select((ClimaxViewModel model) => model.translate);
    backgroundWidget = Transform.translate(
        offset: translate, child: Transform.scale(scale: scaleBackground, child: image));
    return Stack(fit: StackFit.expand, children: [
      _buildBackgroundImage(),
      GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          if (backgroundSelected) {
            climaxModel.translate += details.delta;
          }
        },
        child: GestureDetector(
            onScaleStart: (ScaleStartDetails details) {
              if (backgroundSelected) {
                climaxModel.baseScaleBackground = climaxModel.scaleBackground;
              } else {
                climaxModel.baseScaleClimax = climaxModel.scaleClimax;
              }
            },
            onScaleUpdate: (ScaleUpdateDetails details) {
              print("ScaleUpdate: ${details.scale}");
              if (details.scale == 1) return;
              if (backgroundSelected) {
                climaxModel.scaleBackground = climaxModel.baseScaleBackground * details.scale;
              } else {
                climaxModel.scaleClimax = climaxModel.baseScaleClimax * details.scale;
              }
            },
            child: Container(color: Colors.transparent, child: Climax())),
      ),
    ]);
  }

  Widget _buildBackgroundImage() {
    return backgroundImagePath == null
        ? backgroundWidget
        : FittedBox(fit: BoxFit.fill, child: Image.file(File(backgroundImagePath)));
  }
}


/// TODO
class RouteEditor3 extends StatefulWidget {
  @override
  _RouteEditorState3 createState() => _RouteEditorState3();
}

class _RouteEditorState3 extends State<RouteEditor3> {
  ImageViewModel model;
  String backgroundImagePath;
  ClimaxViewModel climaxModel;

  Widget backgroundWidget;
  Image image = Image.asset("assets/images/routes/route1.png");

  @override
  void initState() {
    super.initState();
    climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    backgroundImagePath = context.select((ImageViewModel model) => model.currentImagePath);
    final backgroundSelected = context.select((ClimaxViewModel model) => model.backgroundSelected);
    final scaleBackground = context.select((ClimaxViewModel model) => model.scaleBackground);
    final Offset translate = context.select((ClimaxViewModel model) => model.translate);
    backgroundWidget = Transform.translate(
        offset: translate, child: Transform.scale(scale: scaleBackground, child: image));
    return Stack(fit: StackFit.expand, children: [
      _buildBackgroundImage(),
      DoubleSwipeGestureDetector(
        onUpdate: (DragUpdateDetails details) {
          // print("DoubleSwipe: $details");
          if (backgroundSelected) {
            climaxModel.translate += details.delta;
          }
        },
        child: GestureDetector(
            onScaleStart: (ScaleStartDetails details) {
              print("BaseScale: ${climaxModel.baseScaleBackground}");
              print("Scale: ${climaxModel.scaleClimax}");
              if (backgroundSelected) {
                climaxModel.baseScaleBackground = climaxModel.scaleBackground;
              } else {
                climaxModel.baseScaleClimax = climaxModel.scaleClimax;
              }
            },
            onScaleUpdate: (ScaleUpdateDetails details) {
              setState(() {
                // print("PanUpdate: ${details.scale}");
                if (details.scale == 1) return;
                if (backgroundSelected) {
                  climaxModel.scaleBackground = climaxModel.baseScaleBackground * details.scale;
                } else {
                  climaxModel.scaleClimax = climaxModel.baseScaleClimax * details.scale;
                }
              });
            },
            child: Container(color: Colors.transparent, child: Climax())),
      ),
    ]);
  }

  Widget _buildBackgroundImage() {
    return backgroundImagePath == null
        ? backgroundWidget
        : FittedBox(fit: BoxFit.fill, child: Image.file(File(backgroundImagePath)));
  }
}
